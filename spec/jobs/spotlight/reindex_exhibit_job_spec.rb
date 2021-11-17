# frozen_string_literal: true

require 'rails_helper'

describe Spotlight::ReindexExhibitJob do
  include ActiveJob::TestHelper
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:url1) { 'http://example.com/1/manifest' }
  let(:manifest) { object_double(CollectionManifest.new, manifests: [{ "@id" => url1 }]) }

  before do
    allow(CollectionManifest).to receive(:find_by_slug).and_return(manifest)
  end

  after do
    clear_enqueued_jobs
  end

  with_queue_adapter :test

  it 'runs the index job inline' do
    allow(Spotlight::ReindexJob).to receive(:perform_later)
    described_class.perform_now(exhibit)

    expect(Spotlight::ReindexJob).to have_received(:perform_later).once
  end
  it "works for resources which aren't persisted yet" do
    stub_manifest(url: url1, fixture: 'full_text_manifest.json')

    described_class.perform_now(exhibit)

    expect(Spotlight::UpdateJobTrackersJob).to have_been_enqueued.exactly(:once)
    expect(Spotlight::ReindexJob).to have_been_enqueued.exactly(:once)
  end
end
