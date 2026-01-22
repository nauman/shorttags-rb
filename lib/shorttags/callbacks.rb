# frozen_string_literal: true

module Shorttags
  # Callbacks module for handling shorttags webhook action callbacks
  #
  # This module provides helpers for Rails controllers to easily handle
  # approve/reject callbacks from shorttags.
  #
  # @example Basic Rails controller usage
  #   class ShorttagsCallbacksController < ApplicationController
  #     include Shorttags::Callbacks
  #
  #     skip_before_action :verify_authenticity_token
  #
  #     def create
  #       callback = parse_callback(request)
  #
  #       if callback.approved?
  #         site = Site.find(callback.payload["site_id"])
  #         site.approve!
  #       elsif callback.rejected?
  #         site = Site.find(callback.payload["site_id"])
  #         site.reject!
  #       end
  #
  #       head :ok
  #     end
  #   end
  #
  # @example With Rails concern pattern
  #   class Api::CallbacksController < Api::BaseController
  #     include Shorttags::Callbacks
  #
  #     def create
  #       handle_shorttags_callback do |callback|
  #         case callback.metric_name
  #         when "pending_site"
  #           handle_site_callback(callback)
  #         when "refund_request"
  #           handle_refund_callback(callback)
  #         end
  #       end
  #     end
  #
  #     private
  #
  #     def handle_site_callback(callback)
  #       site = Site.find(callback.payload["site_id"])
  #       if callback.approved?
  #         site.approve!
  #       else
  #         site.reject!(reason: callback.payload["rejection_reason"])
  #       end
  #     end
  #   end
  #
  module Callbacks
    # Callback data object for easy access to callback properties
    class Callback
      attr_reader :action, :action_request_id, :site, :payload, :decided_at, :decided_by, :metric_name, :raw

      def initialize(data)
        @raw = data
        @action = data["action"]
        @action_request_id = data["action_request_id"]
        @site = data["site"]
        @payload = data["payload"] || {}
        @metric_name = data["metric_name"]
        @decided_at = parse_time(data["decided_at"])
        @decided_by = data["decided_by"]
      end

      # @return [Boolean] true if the action was approved
      def approved?
        @action == "approved"
      end

      # @return [Boolean] true if the action was rejected
      def rejected?
        @action == "rejected"
      end

      # Get a value from the payload
      # @param key [String, Symbol] the key to fetch
      # @return the value or nil
      def [](key)
        @payload[key.to_s] || @payload[key.to_sym]
      end

      private

      def parse_time(value)
        return nil unless value
        Time.parse(value)
      rescue ArgumentError
        nil
      end
    end

    # Parse a callback from a Rails request
    #
    # @param request [ActionDispatch::Request] the Rails request object
    # @return [Callback] parsed callback data
    #
    # @example
    #   callback = parse_callback(request)
    #   if callback.approved?
    #     # handle approval
    #   end
    #
    def parse_callback(request)
      body = if request.respond_to?(:raw_post)
        request.raw_post
      elsif request.respond_to?(:body)
        request.body.read
      else
        request.to_s
      end

      data = JSON.parse(body)
      Callback.new(data)
    end

    # Handle a shorttags callback with a block
    #
    # This method parses the callback and yields it to the block.
    # Returns a 200 OK response by default.
    #
    # @yield [callback] The parsed callback object
    # @return [void]
    #
    # @example
    #   handle_shorttags_callback do |callback|
    #     if callback.approved?
    #       Site.find(callback["site_id"]).approve!
    #     end
    #   end
    #
    def handle_shorttags_callback
      callback = parse_callback(request)
      yield callback if block_given?
      head :ok
    rescue JSON::ParserError => e
      Rails.logger.error "[Shorttags] Failed to parse callback: #{e.message}" if defined?(Rails)
      head :bad_request
    rescue StandardError => e
      Rails.logger.error "[Shorttags] Callback error: #{e.message}" if defined?(Rails)
      head :internal_server_error
    end

    # Verify callback is from shorttags (optional security check)
    #
    # Note: HMAC verification is not yet implemented in shorttags.
    # This method is a placeholder for future security features.
    #
    # @param request [ActionDispatch::Request] the Rails request
    # @param secret [String] the shared secret for HMAC verification
    # @return [Boolean] true if signature is valid
    #
    def verify_callback_signature(request, secret)
      # TODO: Implement when HMAC signatures are added to shorttags
      # signature = request.headers["X-Shorttags-Signature"]
      # return false unless signature
      # expected = OpenSSL::HMAC.hexdigest("SHA256", secret, request.raw_post)
      # Rack::Utils.secure_compare(signature, expected)
      true
    end
  end
end
