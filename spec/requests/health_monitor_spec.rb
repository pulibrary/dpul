# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health Monitor", type: :request do
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

    context "when checking the status of the mounted directory" do
      it "errors when the mount directory is empty" do
        path_mock = Rails.root.join("spec", "fixtures", "fake_directory").to_s
        uploader_mock = instance_double(Spotlight::FeaturedImageUploader)
        allow(uploader_mock).to receive(:root).and_return(path_mock)
        allow(Spotlight::FeaturedImageUploader).to receive(:new).and_return(uploader_mock)

        get "/health.json?providers[]=mountstatus"

        expect(response).not_to be_successful
        expect(JSON.parse(response.body)["results"].first["message"]).to match(/uploads mount .*uploads\/spotlight is empty/)
      end

      it "succeeds when the mount directory has contents" do
        get "/health.json?providers[]=mountstatus"

        expect(response).to be_successful
        expect(JSON.parse(response.body)["results"].first["status"]).to eq "OK"
      end
    end
  end
end
