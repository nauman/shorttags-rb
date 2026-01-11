# frozen_string_literal: true

require_relative "shorttags/version"
require_relative "shorttags/configuration"
require_relative "shorttags/client"
require_relative "shorttags/events/base"
require_relative "shorttags/events/user_registered"
require_relative "shorttags/events/user_logged_in"
require_relative "shorttags/events/user_paid"
require_relative "shorttags/events/subscription_changed"
require_relative "shorttags/events/feature_used"
require_relative "shorttags/events/error_occurred"
require_relative "shorttags/events/metric_recorded"
require_relative "shorttags/events/pageview_tracked"
require_relative "shorttags/events/visitor_tracked"
require_relative "shorttags/events/session_tracked"

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

    # Track a user login
    #
    # @param extra [Hash] Additional data (user_id, method, etc.)
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.login
    #   Shorttags.login(method: "magic_link")
    #
    def login(extra = {})
      Events::UserLoggedIn.track(extra)
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

    # Track a subscription change
    #
    # @param tier [String] New subscription tier
    # @param extra [Hash] Additional data (mrr, previous_tier, etc.)
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.subscription("pro")
    #   Shorttags.subscription("pro", mrr: 29.00)
    #
    def subscription(tier, extra = {})
      Events::SubscriptionChanged.track(extra.merge(tier: tier))
    end

    # Track feature usage
    #
    # @param feature [String, Symbol] Feature name
    # @param extra [Hash] Additional data
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.feature_used(:export)
    #   Shorttags.feature_used(:api, endpoint: "/metrics")
    #
    def feature_used(feature, extra = {})
      Events::FeatureUsed.track(extra.merge(feature: feature))
    end

    # Track an error occurrence
    #
    # @param error_type [String, Symbol] Error type/category
    # @param extra [Hash] Additional data (message, etc.)
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.error(:validation)
    #   Shorttags.error(:api, message: "Rate limit exceeded")
    #
    def error(error_type, extra = {})
      Events::ErrorOccurred.track(extra.merge(type: error_type))
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

    # Track a pageview
    #
    # @param count [Integer] Number of pageviews (default: 1)
    # @param extra [Hash] Additional data (path, referrer, etc.)
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.pageview
    #   Shorttags.pageview(1, path: "/pricing")
    #   Shorttags.pageview(5, unique_pageviews: 3)
    #
    def pageview(count = 1, extra = {})
      Events::PageviewTracked.track(extra.merge(count: count))
    end

    # Track a visitor
    #
    # @param count [Integer] Number of visitors (default: 1)
    # @param extra [Hash] Additional data (source, country, etc.)
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.visitor
    #   Shorttags.visitor(1, source: "google")
    #   Shorttags.visitor(10, country: "US")
    #
    def visitor(count = 1, extra = {})
      Events::VisitorTracked.track(extra.merge(count: count))
    end

    # Track a session/visit
    #
    # @param count [Integer] Number of sessions (default: 1)
    # @param extra [Hash] Additional data (duration, bounce, etc.)
    # @return [Hash] API response
    #
    # @example
    #   Shorttags.session
    #   Shorttags.session(1, duration: 120)
    #   Shorttags.session(1, bounce: true)
    #
    def session(count = 1, extra = {})
      Events::SessionTracked.track(extra.merge(count: count))
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
