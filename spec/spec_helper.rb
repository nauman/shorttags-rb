# frozen_string_literal: true

require "shorttags"
require "webmock/rspec"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Shorttags.reset_configuration!
    Shorttags.reset_client!
  end
end
