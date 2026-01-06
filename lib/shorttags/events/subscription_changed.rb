# frozen_string_literal: true

module Shorttags
  module Events
    class SubscriptionChanged < Base
      def to_metrics
        metrics = { subscriptions: 1 }
        metrics["tier_#{data[:tier]}".to_sym] = 1 if data[:tier]
        metrics[:mrr] = data[:mrr] if data[:mrr]
        metrics.merge(data.except(:tier, :mrr))
      end
    end
  end
end
