# frozen_string_literal: true

module Shorttags
  module Events
    class UserRegistered < Base
      def to_metrics
        { signups: 1 }.merge(numeric_data)
      end
    end
  end
end
