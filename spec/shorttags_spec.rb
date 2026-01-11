# frozen_string_literal: true

RSpec.describe Shorttags do
  let(:api_endpoint) { "https://shorttags.com/api/notify/test-site" }

  it "has a version number" do
    expect(Shorttags::VERSION).not_to be_nil
  end

  describe ".configure" do
    it "yields configuration object" do
      Shorttags.configure do |config|
        config.api_key = "test-key"
        config.site_id = "test-site"
      end

      expect(Shorttags.configuration.api_key).to eq("test-key")
      expect(Shorttags.configuration.site_id).to eq("test-site")
    end
  end

  describe ".track" do
    before do
      Shorttags.configure do |config|
        config.api_key = "test-key"
        config.site_id = "test-site"
      end
    end

    it "sends metrics to API" do
      stub = stub_request(:post, api_endpoint)
        .with(
          body: '{"signups":1}',
          headers: { "X-Api-Key" => "test-key", "Content-Type" => "application/json" }
        )
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.track(signups: 1)

      expect(stub).to have_been_requested
    end
  end

  describe ".signup" do
    before do
      Shorttags.configure do |config|
        config.api_key = "test-key"
        config.site_id = "test-site"
      end
    end

    it "tracks signup event" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("signups" => 1))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.signup

      expect(stub).to have_been_requested
    end

    it "includes extra data" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("signups" => 1, "plan" => "pro"))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.signup(plan: "pro")

      expect(stub).to have_been_requested
    end
  end

  describe ".payment" do
    before do
      Shorttags.configure do |config|
        config.api_key = "test-key"
        config.site_id = "test-site"
      end
    end

    it "tracks payment with amount" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("payments" => 1, "revenue" => 99.0))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.payment(99.0)

      expect(stub).to have_been_requested
    end
  end

  describe ".event" do
    before do
      Shorttags.configure do |config|
        config.api_key = "test-key"
        config.site_id = "test-site"
      end
    end

    it "tracks custom event with default value" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("page_views" => 1))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.event(:page_views)

      expect(stub).to have_been_requested
    end

    it "tracks custom event with custom value" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("api_calls" => 5))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.event(:api_calls, 5)

      expect(stub).to have_been_requested
    end
  end

  describe ".pageview" do
    before do
      Shorttags.configure do |config|
        config.api_key = "test-key"
        config.site_id = "test-site"
      end
    end

    it "tracks pageview with default count" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("pageviews" => 1))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.pageview

      expect(stub).to have_been_requested
    end

    it "tracks pageview with custom count and extra data" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("pageviews" => 5, "path" => "/pricing"))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.pageview(5, path: "/pricing")

      expect(stub).to have_been_requested
    end
  end

  describe ".visitor" do
    before do
      Shorttags.configure do |config|
        config.api_key = "test-key"
        config.site_id = "test-site"
      end
    end

    it "tracks visitor with default count" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("visitors" => 1))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.visitor

      expect(stub).to have_been_requested
    end

    it "tracks visitor with extra data" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("visitors" => 10, "source" => "google"))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.visitor(10, source: "google")

      expect(stub).to have_been_requested
    end
  end

  describe ".session" do
    before do
      Shorttags.configure do |config|
        config.api_key = "test-key"
        config.site_id = "test-site"
      end
    end

    it "tracks session with default count" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("sessions" => 1))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.session

      expect(stub).to have_been_requested
    end

    it "tracks session with extra data" do
      stub = stub_request(:post, api_endpoint)
        .with(body: hash_including("sessions" => 1, "duration" => 120))
        .to_return(status: 200, body: '{"success": true}')

      Shorttags.session(1, duration: 120)

      expect(stub).to have_been_requested
    end
  end
end
