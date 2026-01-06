# frozen_string_literal: true

module Shorttags
  module Events
    class ErrorOccurred < Base
      def to_metrics
        error_type = data[:type] || "unknown"
        { errors: 1, "error_#{error_type}".to_sym => 1 }.merge(data.except(:type))
      end
    end
  end
end
