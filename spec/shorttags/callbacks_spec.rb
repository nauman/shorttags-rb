# frozen_string_literal: true

RSpec.describe Shorttags::Callbacks do
  let(:test_class) do
    Class.new do
      include Shorttags::Callbacks

      attr_accessor :request, :response_status

      def head(status)
        @response_status = status
      end
    end
  end

  let(:controller) { test_class.new }

  describe Shorttags::Callbacks::Callback do
    let(:callback_data) do
      {
        "action" => "approved",
        "action_request_id" => 123,
        "site" => "test-site",
        "metric_name" => "pending_site",
        "payload" => { "site_id" => 42, "title" => "My Site" },
        "decided_at" => "2026-01-22T10:30:00Z",
        "decided_by" => "admin@example.com"
      }
    end

    subject(:callback) { described_class.new(callback_data) }

    it "parses action" do
      expect(callback.action).to eq("approved")
    end

    it "parses action_request_id" do
      expect(callback.action_request_id).to eq(123)
    end

    it "parses site" do
      expect(callback.site).to eq("test-site")
    end

    it "parses metric_name" do
      expect(callback.metric_name).to eq("pending_site")
    end

    it "parses payload" do
      expect(callback.payload).to eq({ "site_id" => 42, "title" => "My Site" })
    end

    it "parses decided_at as Time" do
      expect(callback.decided_at).to be_a(Time)
      expect(callback.decided_at.year).to eq(2026)
    end

    it "parses decided_by" do
      expect(callback.decided_by).to eq("admin@example.com")
    end

    it "provides raw data access" do
      expect(callback.raw).to eq(callback_data)
    end

    describe "#approved?" do
      it "returns true when action is approved" do
        expect(callback.approved?).to be true
      end

      it "returns false when action is rejected" do
        rejected = described_class.new(callback_data.merge("action" => "rejected"))
        expect(rejected.approved?).to be false
      end
    end

    describe "#rejected?" do
      it "returns true when action is rejected" do
        rejected = described_class.new(callback_data.merge("action" => "rejected"))
        expect(rejected.rejected?).to be true
      end

      it "returns false when action is approved" do
        expect(callback.rejected?).to be false
      end
    end

    describe "#[]" do
      it "accesses payload by string key" do
        expect(callback["site_id"]).to eq(42)
      end

      it "accesses payload by symbol key" do
        expect(callback[:site_id]).to eq(42)
      end

      it "returns nil for missing keys" do
        expect(callback["nonexistent"]).to be_nil
      end
    end

    context "with empty payload" do
      let(:callback_data) { { "action" => "approved" } }

      it "handles missing payload gracefully" do
        expect(callback.payload).to eq({})
      end
    end

    context "with invalid decided_at" do
      let(:callback_data) { { "action" => "approved", "decided_at" => "invalid" } }

      it "handles invalid time gracefully" do
        expect(callback.decided_at).to be_nil
      end
    end
  end

  describe "#parse_callback" do
    let(:request_body) do
      {
        "action" => "approved",
        "action_request_id" => 123,
        "site" => "test-site",
        "payload" => { "site_id" => 42 }
      }.to_json
    end

    it "parses callback from request with raw_post" do
      request = double(raw_post: request_body)
      controller.request = request

      callback = controller.parse_callback(request)

      expect(callback).to be_a(Shorttags::Callbacks::Callback)
      expect(callback.action).to eq("approved")
      expect(callback.action_request_id).to eq(123)
    end

    it "parses callback from request with body.read" do
      body = double(read: request_body)
      request = double(body: body)

      callback = controller.parse_callback(request)

      expect(callback.action).to eq("approved")
    end

    it "falls back to to_s for unknown request types" do
      request = double(to_s: request_body)
      allow(request).to receive(:respond_to?).with(:raw_post).and_return(false)
      allow(request).to receive(:respond_to?).with(:body).and_return(false)

      callback = controller.parse_callback(request)

      expect(callback.action).to eq("approved")
    end
  end

  describe "#handle_shorttags_callback" do
    let(:valid_request) do
      body = {
        "action" => "approved",
        "action_request_id" => 123,
        "payload" => { "site_id" => 42 }
      }.to_json
      double(raw_post: body)
    end

    before do
      controller.request = valid_request
    end

    it "yields callback to block" do
      yielded_callback = nil

      controller.handle_shorttags_callback do |callback|
        yielded_callback = callback
      end

      expect(yielded_callback).to be_a(Shorttags::Callbacks::Callback)
      expect(yielded_callback.action).to eq("approved")
    end

    it "returns head :ok by default" do
      controller.handle_shorttags_callback {}

      expect(controller.response_status).to eq(:ok)
    end

    it "handles JSON parse errors" do
      controller.request = double(raw_post: "invalid json")

      controller.handle_shorttags_callback {}

      expect(controller.response_status).to eq(:bad_request)
    end

    it "handles other errors" do
      controller.handle_shorttags_callback do
        raise StandardError, "Something went wrong"
      end

      expect(controller.response_status).to eq(:internal_server_error)
    end
  end

  describe "#verify_callback_signature" do
    it "returns true (placeholder for future HMAC verification)" do
      request = double
      secret = "test-secret"

      result = controller.verify_callback_signature(request, secret)

      expect(result).to be true
    end
  end
end
