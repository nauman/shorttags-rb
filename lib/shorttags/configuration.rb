# frozen_string_literal: true

module Shorttags
  class Configuration
    attr_accessor :api_key, :site_id, :base_url, :timeout, :open_timeout

    def initialize
      @base_url = "https://shorttags.com"
      @timeout = 30
      @open_timeout = 10
    end

    def valid?
      !api_key.nil? && !api_key.empty? && !site_id.nil? && !site_id.empty?
    end

    def api_endpoint
      "#{base_url}/api/v1/metrics"
    end
  end
end
