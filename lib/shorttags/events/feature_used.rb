# frozen_string_literal: true

module Shorttags
  module Events
    class FeatureUsed < Base
      def to_metrics
        feature = data[:feature] || "unknown"
        { "feature_#{feature}".to_sym => 1 }.merge(data.except(:feature))
      end
    end
  end
end
