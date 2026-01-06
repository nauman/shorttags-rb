# frozen_string_literal: true

module Shorttags
  module Events
    class MetricRecorded < Base
      def to_metrics
        data
      end
    end
  end
end
