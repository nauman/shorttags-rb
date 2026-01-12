# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Shorttags
  class Client
    class Error < StandardError; end
    class ConfigurationError < Error; end
    class ApiError < Error; end

    def initialize(configuration = nil)
      @config = configuration || Shorttags.configuration
    end

    def track(metrics)
      return { skipped: true, reason: "tracking disabled" } unless @config.enabled?
      validate_configuration!

      uri = URI.parse(@config.api_endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @config.open_timeout
      http.read_timeout = @config.timeout

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["X-API-Key"] = @config.api_key

      # API expects flat hash of metrics: { metric_name: value }
      request.body = normalize_metrics(metrics).to_json

      response = http.request(request)

      handle_response(response)
    rescue ConfigurationError, ApiError
      raise
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise ApiError, "Request timed out: #{e.message}"
    rescue StandardError => e
      raise ApiError, "Request failed: #{e.message}"
    end

    private

    def validate_configuration!
      unless @config.valid?
        raise ConfigurationError, "Shorttags is not properly configured. Please set api_key and site_id."
      end
    end

    def normalize_metrics(metrics)
      case metrics
      when Hash
        metrics.transform_keys(&:to_s)
      when Array
        metrics.map { |m| normalize_metrics(m) }
      else
        metrics
      end
    end

    def handle_response(response)
      case response.code.to_i
      when 200..299
        JSON.parse(response.body) rescue { success: true }
      when 401
        raise ApiError, "Invalid API key"
      when 404
        raise ApiError, "Site not found"
      when 422
        body = JSON.parse(response.body) rescue {}
        raise ApiError, "Validation error: #{body['error'] || body['errors'] || 'Unknown error'}"
      when 429
        raise ApiError, "Rate limit exceeded"
      else
        raise ApiError, "API returned #{response.code}: #{response.body}"
      end
    end
  end
end
