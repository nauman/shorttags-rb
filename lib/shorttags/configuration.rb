# frozen_string_literal: true

module Shorttags
  class Configuration
    attr_accessor :api_key, :site_id, :base_url, :timeout, :open_timeout
    attr_writer :enabled

    def initialize
      @base_url = "https://shorttags.com"
      @timeout = 30
      @open_timeout = 10
      @enabled = nil # nil means auto-detect
    end

    # Check if tracking is enabled
    # - If explicitly set, use that value
    # - If Rails is present, only enable in production
    # - Otherwise, enable by default
    def enabled?
      return @enabled unless @enabled.nil?

      if defined?(Rails)
        Rails.env.production?
      else
        true
      end
    end

    def valid?
      !api_key.nil? && !api_key.empty? && !site_id.nil? && !site_id.empty?
    end

    def api_endpoint
      "#{base_url}/api/notify/#{site_id}"
    end

    def accumulator_endpoint
      "#{base_url}/api/notify/#{site_id}/accumulators"
    end
  end
end
