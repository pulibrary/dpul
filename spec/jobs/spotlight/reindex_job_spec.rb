# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spotlight::ReindexJob do
  let(:url1) { 'http://example.com/1/manifest' }
  let(:exhibit) { Spotlight::Exhibit.new }
  let(:resource) { IIIFResource.new url: nil, exhibit: exhibit }
  let(:manifest) { object_double(CollectionManifest.new, manifests: [{ "@id" => url1 }]) }

  before do
    allow(exhibit).to receive(:id).and_return('exhibit1')
    allow(Spotlight::Exhibit).to receive(:find).with('exhibit1').and_return(exhibit)
    allow(CollectionManifest).to receive(:find_by_slug).and_return(manifest)
    allow(resource).to receive(:save_and_index_now)
  end

  it 'reindexes an exhibit' do
    allow(IIIFResource).to receive(:new).and_return(resource)

    described_class.perform_now(exhibit)

    expect(IIIFResource).to have_received(:new).with("type" => "IIIFResource", url: url1, exhibit_id: exhibit.id)
  end

  it 'can reindex multiple IIIF Resources' do
    resources = [instance_double(IIIFResource, reindex: true), instance_double(IIIFResource, reindex: true)]

    described_class.perform_now(resources)

    expect(resources.first).to have_received(:reindex)
    expect(resources.last).to have_received(:reindex)
  end

  context 'with an existing log entry' do
    let(:log_entry) { Spotlight::ReindexingLogEntry.new }
    let(:resource1) { instance_double(IIIFResource, reindex: true) }
    let(:resource2) { instance_double(IIIFResource, reindex: true) }
    let(:resources) { [resource1, resource2] }
    let(:builder) { double("Spotlight::SolrDocumentBuilder") }

    before do
      allow(builder).to receive(:documents_to_index).and_return([0])
      # allow(resource1).to receive(:document_builder).and_return(builder)
      # allow(resource2).to receive(:document_builder).and_return(builder)
      allow(log_entry).to receive(:update)
    end

    it 'estimates the number of items being reindexed' do
      described_class.perform_now(resources, log_entry)
      expect(log_entry).to have_received(:update).with(items_reindexed_estimate: 2)
    end

    context 'when the job fails' do
      before do
        allow(resource1).to receive(:reindex).and_raise(StandardError)
        allow(log_entry).to receive(:failed!)
      end

      it 'sets the state of the job to failure within the log entry' do
        expect { described_class.perform_now(resources, log_entry) }.to raise_error(StandardError)
        expect(log_entry).to have_received(:failed!)
      end
    end
  end
end
