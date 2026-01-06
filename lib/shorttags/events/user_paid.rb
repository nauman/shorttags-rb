# frozen_string_literal: true

module Shorttags
  module Events
    class UserPaid < Base
      def to_metrics
        metrics = { payments: 1 }
        metrics[:revenue] = data[:amount] if data[:amount]
        metrics[:mrr] = data[:mrr] if data[:mrr]
        metrics.merge(data.except(:amount, :mrr))
      end
    end
  end
end
