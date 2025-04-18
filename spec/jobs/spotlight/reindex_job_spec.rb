# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spotlight::ReindexJob do
  with_queue_adapter :inline
  let(:url1) { 'http://example.com/1/manifest' }
  let(:exhibit) { Spotlight::Exhibit.new }
  let(:resource) { IiifResource.new url: nil, exhibit: }
  let(:manifest) { object_double(CollectionManifest.new, manifests: [{ "@id" => url1 }]) }

  let(:iiif_resource1) do FactoryBot.create(
    :iiif_resource,
    url: "https://figgy.princeton.edu/concern/scanned_resources/beaec815-6a34-4519-8ce8-40a89d3b1956/manifest",
    exhibit:,
    manifest_fixture: "paris_map.json",
    figgy_uuid: "beaec815-6a34-4519-8ce8-40a89d3b1956",
    spec: self
  )
  end

  let(:iiif_resource2) do FactoryBot.create(
    :iiif_resource,
    url: "https://figgy.princeton.edu/concern/scanned_resources/0cc43bdb-ae21-47b2-90bc-bc21a18ee821/manifest",
    exhibit:,
    manifest_fixture: "chinese_medicine.json",
    figgy_uuid: "0cc43bdb-ae21-47b2-90bc-bc21a18ee821",
    spec: self
  )
  end

  before do
    allow(exhibit).to receive(:id).and_return('exhibit1')
    exhibit.id = "exhibit1"
    allow(exhibit).to receive(:touch)
    allow(Spotlight::Exhibit).to receive(:find).with('exhibit1').and_return(exhibit)
    allow(CollectionManifest).to receive(:find_by_slug).and_return(manifest)
    allow(resource).to receive(:save_and_index_now)
  end

  it 'reindexes an exhibit' do
    allow(IiifResource).to receive(:new).and_return(resource)

    described_class.perform_now(exhibit)

    expect(IiifResource).to have_received(:new).with(url: url1, exhibit_id: exhibit.id)
  end

  it 'can reindex multiple IIIF Resources' do
    resources = [iiif_resource1, iiif_resource2]
    allow(resources.first).to receive(:reindex)
    allow(resources.last).to receive(:reindex)

    described_class.perform_now(resources)

    expect(resources.first).to have_received(:reindex)
    expect(resources.last).to have_received(:reindex)
  end

  context 'when there is an error' do
    it 'logs the error in the job tracker and raises it so sidekiq can retry' do
      allow(iiif_resource1).to receive(:reindex).and_raise StandardError
      allow(IiifResource).to receive(:new).and_return(resource)

      expect { described_class.perform_now(iiif_resource1) }.to raise_error(StandardError)

      job_tracker = Spotlight::JobTracker.last
      event = job_tracker.events.last
      expect(event[:data][:errors]).to eq 1
    end
  end
end
