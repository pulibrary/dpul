# frozen_string_literal: true

require "rails_helper"

describe Spotlight::ReindexExhibitJob do
  include ActiveJob::TestHelper
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:url1) { "http://example.com/1/manifest" }
  let(:manifest) { object_double(CollectionManifest.new, manifests: [{ "@id" => url1 }]) }

  before do
    allow(CollectionManifest).to receive(:find_by_slug).and_return(manifest)
    allow(Spotlight::UpdateJobTrackersJob).to receive(:perform_now).and_call_original
  end

  after do
    clear_enqueued_jobs
  end

  it "runs the index job inline" do
    stub_manifest(url: url1, fixture: "full_text_manifest.json")
    allow(Spotlight::ReindexJob).to receive(:perform_later)
    described_class.perform_now(exhibit)

    expect(Spotlight::ReindexJob).to have_received(:perform_later).once
  end

  it "works for resources which aren't persisted yet" do
    stub_manifest(url: url1, fixture: "full_text_manifest.json")

    described_class.perform_now(exhibit)

    expect(Spotlight::UpdateJobTrackersJob).to have_received(:perform_now).exactly(:once)
    expect(Spotlight::ReindexJob).to have_been_enqueued.exactly(:once)
  end

  it "works for resources which aren't persisted yet, even if they timeout on save validation" do
    stub_request(:get, url1)
      .to_return(status: 200, body: File.read(Rails.root.join("spec", "fixtures", "manifests", "full_text_manifest.json")), headers: { "content-type" => "application/ld+json" })
    # head request should fail first, because of the save
    stub_request(:head, url1)
      .to_timeout.then
      .to_return(status: 200, body: "", headers: { "content-type" => "application/ld+json" })
    described_class.perform_now(exhibit)

    expect(Spotlight::UpdateJobTrackersJob).to have_received(:perform_now).exactly(:once)
    expect(Spotlight::ReindexJob).to have_been_enqueued.exactly(:once)
  end

  it "skips over resources which there's no permission for" do
    stub_manifest(url: url1, fixture: "full_text_manifest.json", status: 403)
    described_class.perform_now(exhibit)

    expect(Spotlight::UpdateJobTrackersJob).not_to have_received(:perform_now)
    expect(Spotlight::ReindexJob).not_to have_been_enqueued
  end

  context "when a resource head request times out" do
    # these are the urls from spec/fixtures/manifests/2b88qc199.json
    let(:url1) { "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest" }
    let(:url2) { "https://hydra-dev.princeton.edu/concern/scanned_resources/44558d29f/manifest" }
    let(:manifest) { object_double(CollectionManifest.new, manifests: [{ "@id" => url1 }, { "@id" => url2 }]) }

    it "retries indexing" do
      # get request can always succeed
      stub_request(:get, url1)
        .to_return(status: 200, body: File.read(Rails.root.join("spec", "fixtures", "manifests", "1r66j1149.json")), headers: { "content-type" => "application/ld+json" })
      # head request should succeed first, because of the save
      stub_request(:head, url1)
        .to_return(status: 200, body: "", headers: { "content-type" => "application/ld+json" }).then
        .to_timeout.then
        .to_timeout.then
        .to_return(status: 200, body: "", headers: { "content-type" => "application/ld+json" })
      # url2 resource has no issues
      stub_manifest(url: url2, fixture: "44558d29f.json")

      allow(Honeybadger).to receive(:notify)
      allow(Spotlight::ReindexJob).to receive(:perform_later)

      described_class.perform_now(exhibit)

      expect(Spotlight::ReindexJob).to have_received(:perform_later).twice
      job_tracker = Spotlight::JobTracker.where(resource_id: exhibit.id).first
      expect(job_tracker.status).to eq "completed"
      expect(Honeybadger).not_to have_received(:notify)
    end

    it "notifies Honeybadger if all retries fail" do
      stub_request(:head, url1).to_timeout
      # url2 resource has no issues
      stub_manifest(url: url2, fixture: "44558d29f.json")

      allow(Spotlight::ReindexJob).to receive(:perform_later)
      allow(Honeybadger).to receive(:notify)

      described_class.perform_now(exhibit)

      expect(Spotlight::ReindexJob).to have_received(:perform_later).once
      job_tracker = Spotlight::JobTracker.where(resource_id: exhibit.id).first
      expect(job_tracker.status).to eq "failed"
      expect(Honeybadger).to have_received(:notify).with("Exhibit index failure on #{exhibit.slug}, with timeout errors on #{url1}")
    end
  end
end
