# frozen_string_literal: true

module Shorttags
  module Events
    class Base
      attr_reader :data

      def initialize(data = {})
        @data = data
      end

      def to_metrics
        raise NotImplementedError, "Subclasses must implement #to_metrics"
      end

      def track
        Shorttags.track(to_metrics)
      end

      # Filter data to only include numeric values (metrics)
      # Non-numeric values (strings, etc.) are ignored
      def numeric_data
        data.select { |_k, v| v.is_a?(Numeric) }
      end

      class << self
        def track(data = {})
          new(data).track
        end
      end
    end
  end
end
