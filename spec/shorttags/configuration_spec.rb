# frozen_string_literal: true

RSpec.describe Shorttags::Configuration do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it "sets default base_url" do
      expect(config.base_url).to eq("https://shorttags.com")
    end

    it "sets default timeout" do
      expect(config.timeout).to eq(30)
    end

    it "sets default open_timeout" do
      expect(config.open_timeout).to eq(10)
    end
  end

  describe "#valid?" do
    it "returns false when api_key is nil" do
      config.site_id = "test"
      expect(config.valid?).to be false
    end

    it "returns false when site_id is nil" do
      config.api_key = "test"
      expect(config.valid?).to be false
    end

    it "returns false when api_key is empty" do
      config.api_key = ""
      config.site_id = "test"
      expect(config.valid?).to be false
    end

    it "returns true when both are set" do
      config.api_key = "test-key"
      config.site_id = "test-site"
      expect(config.valid?).to be true
    end
  end

  describe "#api_endpoint" do
    before do
      config.site_id = "my-site"
    end

    it "returns the full API URL with site_id" do
      expect(config.api_endpoint).to eq("https://shorttags.com/api/notify/my-site")
    end

    it "uses custom base_url" do
      config.base_url = "https://custom.example.com"
      expect(config.api_endpoint).to eq("https://custom.example.com/api/notify/my-site")
    end
  end
end
