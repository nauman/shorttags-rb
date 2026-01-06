# frozen_string_literal: true

require_relative "shorttags/version"
require_relative "shorttags/configuration"
require_relative "shorttags/client"
require_relative "shorttags/events/base"
require_relative "shorttags/events/user_registered"
require_relative "shorttags/events/user_paid"
require_relative "shorttags/events/metric_recorded"

module Shorttags
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    # Track custom metrics
    #
    # @param metrics [Hash] The metrics to track
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.track(page_views: 1, unique_visitors: 1)
    #
    def track(metrics)
      client.track(metrics)
    end

    # Track a user signup
    #
    # @param extra [Hash] Additional data to include
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.signup
    #   Shorttags.signup(plan: "free")
    #
    def signup(extra = {})
      Events::UserRegistered.track(extra)
    end

    # Track a payment/revenue event
    #
    # @param amount [Numeric] Payment amount
    # @param extra [Hash] Additional data (mrr, plan, etc.)
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.payment(99.00)
    #   Shorttags.payment(99.00, mrr: 99.00, plan: "pro")
    #
    def payment(amount, extra = {})
      Events::UserPaid.track(extra.merge(amount: amount))
    end

    # Create and track a custom event
    #
    # @param name [String, Symbol] Event name (used as metric key)
    # @param value [Numeric] Event value (default: 1)
    # @param extra [Hash] Additional metrics to include
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.event(:file_uploads)
    #   Shorttags.event(:api_calls, 5)
    #   Shorttags.event(:orders, 1, revenue: 150.00)
    #
    def event(name, value = 1, extra = {})
      Events::MetricRecorded.track({ name.to_sym => value }.merge(extra))
    end

    # Get the client instance
    #
    # @return [Client] The configured client
    #
    def client
      @client ||= Client.new
    end

    # Reset the client (useful after reconfiguration)
    def reset_client!
      @client = nil
    end
  end
end
