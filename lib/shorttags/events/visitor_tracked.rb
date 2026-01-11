# frozen_string_literal: true

module Shorttags
  module Events
    class VisitorTracked < Base
      def to_metrics
        count = data.fetch(:count, 1)
        { visitors: count }.merge(data.except(:count))
      end
    end
  end
end
