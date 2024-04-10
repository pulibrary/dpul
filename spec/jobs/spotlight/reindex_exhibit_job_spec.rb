# frozen_string_literal: true

require 'rails_helper'

describe Spotlight::ReindexExhibitJob do
  include ActiveJob::TestHelper
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:url1) { 'http://example.com/1/manifest' }
  let(:manifest) { object_double(CollectionManifest.new, manifests: [{ "@id" => url1 }]) }

  before do
    allow(CollectionManifest).to receive(:find_by_slug).and_return(manifest)
    allow(Spotlight::UpdateJobTrackersJob).to receive(:perform_now).and_call_original
  end

  after do
    clear_enqueued_jobs
  end

  it 'runs the index job inline' do
    stub_manifest(url: url1, fixture: 'full_text_manifest.json')
    allow(Spotlight::ReindexJob).to receive(:perform_later)
    described_class.perform_now(exhibit)

    expect(Spotlight::ReindexJob).to have_received(:perform_later).once
  end

  it "works for resources which aren't persisted yet" do
    stub_manifest(url: url1, fixture: 'full_text_manifest.json')

    described_class.perform_now(exhibit)

    expect(Spotlight::UpdateJobTrackersJob).to have_received(:perform_now).exactly(:once)
    expect(Spotlight::ReindexJob).to have_been_enqueued.exactly(:once)
  end

  it "skips over resources which there's no permission for" do
    stub_manifest(url: url1, fixture: 'full_text_manifest.json', status: 403)
    described_class.perform_now(exhibit)

    expect(Spotlight::UpdateJobTrackersJob).not_to have_received(:perform_now)
    expect(Spotlight::ReindexJob).not_to have_been_enqueued
  end

  context "when a resource head request times out" do
    # these are the urls from spec/fixtures/manifests/2b88qc199.json
    let(:url1) { "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest" }
    let(:url2) { "https://hydra-dev.princeton.edu/concern/scanned_resources/44558d29f/manifest" }

    let(:manifest) { object_double(CollectionManifest.new, manifests: [{ "@id" => url1 }, { "@id" => url2 }]) }
    it "indexes everything else at least" do
      # TODO: keep a list and retry them?
      allow(Spotlight::ReindexJob).to receive(:perform_later)
      # url1: Timeout the first time
      stub_request(:head, url1).to_raise(Faraday::TimeoutError)
      # # url1: get the response the second time (on retry)
      # stub_manifest(url: url1, fixture: "1r66j1149.json")
      stub_manifest(url: url2, fixture: "44558d29f.json")

      described_class.perform_now(exhibit)

      expect(Spotlight::ReindexJob).to have_received(:perform_later).once
      expect(Spotlight::ReindexJob).to have_received(:perform_later) do |arg|
        expect(arg.url).to eq(url2)
      end
      job_tracker = Spotlight::JobTracker.where(resource_id: exhibit.id).first
      expect(job_tracker.status).to eq "failed"
    end
  end
end
