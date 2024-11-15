# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health Check", type: :request do
  describe "GET /health" do
    it "has a success response even if there are failures to non-critical services (e.g smtp)" do
      SmtpStatus.next_check_timestamp = 0
      get '/health.json'

      expect(response).to be_successful
    end

    it "errors when it can't contact the SMTP server when the provider is included" do
      SmtpStatus.next_check_timestamp = 0
      get "/health.json?providers[]=smtpstatus"

      expect(response).not_to be_successful
    end

    it "errors when there's a failure to a critical service (e.g. solr)" do
      allow(Blacklight.default_index.connection).to receive(:uri).and_return(URI("http://example.com/bla"))
      stub_request(:get, "http://example.com/solr/admin/cores?action=STATUS").to_return(body: { responseHeader: { status: 500 } }.to_json, headers: { "Content-Type" => "text/json" })

      get "/health.json"

      expect(response).not_to be_successful
    end

    it "caches a success on SMTP and doesn't call it twice in a short window" do
      smtp_double = instance_double(Net::SMTP)
      allow(Net::SMTP).to receive(:new).and_return(smtp_double)
      allow(smtp_double).to receive(:open_timeout=)
      allow(smtp_double).to receive(:start)

      get "/health.json?providers[]=smtpstatus"
      expect(response).to be_successful
      get "/health.json?providers[]=smtpstatus"

      expect(Net::SMTP).to have_received(:new).exactly(1).times
    end

    it "errors when solr is down" do
      allow(Blacklight.default_index.connection).to receive(:uri).and_return(URI("http://example.com/bla"))
      stub_request(:get, "http://example.com/solr/admin/cores?action=STATUS").to_return(body: { responseHeader: { status: 500 } }.to_json, headers: { "Content-Type" => "text/json" })

      get "/health.json?providers[]=solrstatus"

      expect(response).not_to be_successful
      expect(response.status).to eq 503
      solr_response = JSON.parse(response.body)["results"].find { |x| x["name"] == "SolrStatus" }
      expect(solr_response["message"]).to start_with "The solr has an invalid status"
    end
  end
end
