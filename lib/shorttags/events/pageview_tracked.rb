# frozen_string_literal: true

module Shorttags
  module Events
    class PageviewTracked < Base
      def to_metrics
        count = data.fetch(:count, 1)
        { pageviews: count }.merge(data.except(:count))
      end
    end
  end
end
