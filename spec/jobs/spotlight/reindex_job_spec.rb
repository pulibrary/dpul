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
    allow(resource).to receive(:save_and_index)
  end

  it 'reindexes an exhibit' do
    allow(IIIFResource).to receive(:new).and_return(resource)

    described_class.perform_now(exhibit)

    expect(IIIFResource).to have_received(:new).with(url: url1, exhibit_id: exhibit.id)
  end

  it 'can reindex multiple IIIF Resources' do
    resources = [instance_double(IIIFResource, reindex: true), instance_double(IIIFResource, reindex: true)]

    described_class.perform_now(resources)

    expect(resources.first).to have_received(:reindex)
    expect(resources.last).to have_received(:reindex)
  end
end
