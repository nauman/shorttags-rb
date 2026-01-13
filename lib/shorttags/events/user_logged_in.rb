# frozen_string_literal: true

module Shorttags
  module Events
    class UserLoggedIn < Base
      def to_metrics
        { logins: 1 }.merge(numeric_data)
      end
    end
  end
end
