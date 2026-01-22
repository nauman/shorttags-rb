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

      expect { client.track({ signups: 1 }) }
        .to raise_error(Shorttags::Client::ConfigurationError)
    end

    it "sends POST request to API" do
      stub = stub_request(:post, "https://shorttags.com/api/notify/test-site")
        .with(
          body: '{"signups":1}',
          headers: { "X-Api-Key" => "test-key", "Content-Type" => "application/json" }
        )
        .to_return(status: 200, body: '{"success": true}')

      client.track({ signups: 1 })

      expect(stub).to have_been_requested
    end

    it "sends actionable request when actionable: true" do
      stub = stub_request(:post, "https://shorttags.com/api/notify/test-site?actionable=true")
        .with(body: hash_including("signups" => 1))
        .to_return(status: 200, body: '{"success": true}')

      client.track({ signups: 1 }, actionable: true)

      expect(stub).to have_been_requested
    end

    it "includes payload in body when actionable" do
      stub = stub_request(:post, "https://shorttags.com/api/notify/test-site?actionable=true")
        .with(body: hash_including("signups" => 1, "_payload" => { "id" => 42 }))
        .to_return(status: 200, body: '{"success": true}')

      client.track({ signups: 1 }, actionable: true, payload: { id: 42 })

      expect(stub).to have_been_requested
    end

    it "does not include payload when not actionable" do
      stub = stub_request(:post, "https://shorttags.com/api/notify/test-site")
        .with { |req| !req.body.include?("_payload") }
        .to_return(status: 200, body: '{"success": true}')

      client.track({ signups: 1 }, payload: { id: 42 })

      expect(stub).to have_been_requested
    end

    it "raises ApiError on 401" do
      stub_request(:post, "https://shorttags.com/api/notify/test-site")
        .to_return(status: 401, body: '{"error": "Invalid API key"}')

      expect { client.track({ signups: 1 }) }
        .to raise_error(Shorttags::Client::ApiError, "Invalid API key")
    end

    it "raises ApiError on 404" do
      stub_request(:post, "https://shorttags.com/api/notify/test-site")
        .to_return(status: 404, body: '{"error": "Site not found"}')

      expect { client.track({ signups: 1 }) }
        .to raise_error(Shorttags::Client::ApiError, "Site not found")
    end

    it "raises ApiError on 429" do
      stub_request(:post, "https://shorttags.com/api/notify/test-site")
        .to_return(status: 429, body: '{"error": "Rate limit exceeded"}')

      expect { client.track({ signups: 1 }) }
        .to raise_error(Shorttags::Client::ApiError, "Rate limit exceeded")
    end
  end

  describe "#accumulate" do
    it "raises ConfigurationError when not configured" do
      Shorttags.reset_configuration!

      expect { client.accumulate(total_users: 100) }
        .to raise_error(Shorttags::Client::ConfigurationError)
    end

    it "sends PUT request to accumulators endpoint" do
      stub = stub_request(:put, "https://shorttags.com/api/notify/test-site/accumulators")
        .with(
          body: '{"total_users":100,"total_orders":50}',
          headers: { "X-Api-Key" => "test-key", "Content-Type" => "application/json" }
        )
        .to_return(status: 200, body: '{"success": true}')

      client.accumulate(total_users: 100, total_orders: 50)

      expect(stub).to have_been_requested
    end

    it "raises ApiError on 401" do
      stub_request(:put, "https://shorttags.com/api/notify/test-site/accumulators")
        .to_return(status: 401, body: '{"error": "Invalid API key"}')

      expect { client.accumulate(total_users: 100) }
        .to raise_error(Shorttags::Client::ApiError, "Invalid API key")
    end

    it "raises ApiError on 404" do
      stub_request(:put, "https://shorttags.com/api/notify/test-site/accumulators")
        .to_return(status: 404, body: '{"error": "Site not found"}')

      expect { client.accumulate(total_users: 100) }
        .to raise_error(Shorttags::Client::ApiError, "Site not found")
    end
  end

  describe "#track_action" do
    it "sends POST request with actionable query param" do
      stub = stub_request(:post, "https://shorttags.com/api/notify/test-site?actionable=true")
        .with(
          headers: { "X-Api-Key" => "test-key", "Content-Type" => "application/json" }
        )
        .to_return(status: 200, body: '{"success": true, "action_request_id": 123}')

      client.track_action(:pending_approval)

      expect(stub).to have_been_requested
    end

    it "includes metric name and value in body" do
      stub = stub_request(:post, "https://shorttags.com/api/notify/test-site?actionable=true")
        .with(body: hash_including("pending_approval" => 1))
        .to_return(status: 200, body: '{"success": true}')

      client.track_action(:pending_approval, 1)

      expect(stub).to have_been_requested
    end

    it "includes payload in request body" do
      stub = stub_request(:post, "https://shorttags.com/api/notify/test-site?actionable=true")
        .with(body: hash_including(
          "pending_site" => 1,
          "_payload" => { "site_id" => 42, "title" => "Test Site", "user_email" => "test@example.com" }
        ))
        .to_return(status: 200, body: '{"success": true}')

      client.track_action(:pending_site, 1, { site_id: 42, title: "Test Site", user_email: "test@example.com" })

      expect(stub).to have_been_requested
    end

    it "returns action_request_id in response" do
      stub_request(:post, "https://shorttags.com/api/notify/test-site?actionable=true")
        .to_return(status: 200, body: '{"success": true, "action_request_id": 456}')

      result = client.track_action(:pending_approval)

      expect(result["action_request_id"]).to eq(456)
    end

    it "raises ApiError on failure" do
      stub_request(:post, "https://shorttags.com/api/notify/test-site?actionable=true")
        .to_return(status: 401, body: '{"error": "Invalid API key"}')

      expect { client.track_action(:pending_approval) }
        .to raise_error(Shorttags::Client::ApiError, "Invalid API key")
    end
  end
end
