# frozen_string_literal: true

RSpec.describe Shorttags::Client do
  let(:client) { described_class.new }

  before do
    Shorttags.configure do |config|
      config.api_key = "test-key"
      config.site_id = "test-site"
    end
  end

  describe "#track" do
    it "raises ConfigurationError when not configured" do
      Shorttags.reset_configuration!

      expect { client.track(signups: 1) }
        .to raise_error(Shorttags::Client::ConfigurationError)
    end

    it "sends POST request to API" do
      stub = stub_request(:post, "https://shorttags.com/api/notify/test-site")
        .with(
          body: '{"signups":1}',
          headers: { "X-Api-Key" => "test-key", "Content-Type" => "application/json" }
        )
        .to_return(status: 200, body: '{"success": true}')

      client.track(signups: 1)

      expect(stub).to have_been_requested
    end

    it "raises ApiError on 401" do
      stub_request(:post, "https://shorttags.com/api/notify/test-site")
        .to_return(status: 401, body: '{"error": "Invalid API key"}')

      expect { client.track(signups: 1) }
        .to raise_error(Shorttags::Client::ApiError, "Invalid API key")
    end

    it "raises ApiError on 404" do
      stub_request(:post, "https://shorttags.com/api/notify/test-site")
        .to_return(status: 404, body: '{"error": "Site not found"}')

      expect { client.track(signups: 1) }
        .to raise_error(Shorttags::Client::ApiError, "Site not found")
    end

    it "raises ApiError on 429" do
      stub_request(:post, "https://shorttags.com/api/notify/test-site")
        .to_return(status: 429, body: '{"error": "Rate limit exceeded"}')

      expect { client.track(signups: 1) }
        .to raise_error(Shorttags::Client::ApiError, "Rate limit exceeded")
    end
  end
end
