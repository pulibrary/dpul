require 'rails_helper'

describe IIIFIngestJob do
  let(:url1) { 'http://example.com/1/manifest' }
  let(:url2) { 'http://example.com/2/manifest' }
  let(:resource) { IIIFResource.new }

  it 'ingests a single url' do
    allow_any_instance_of(IIIFResource).to receive(:save)
    expect(IIIFResource).to receive(:new).with(manifest_url: url1).and_return(resource)

    described_class.new.perform(url1)
  end

  it 'ingests each of an array of urls' do
    allow_any_instance_of(IIIFResource).to receive(:save)
    expect(IIIFResource).to receive(:new).with(manifest_url: url1).and_return(resource)
    expect(IIIFResource).to receive(:new).with(manifest_url: url2).and_return(resource)

    described_class.new.perform([url1, url2])
  end
end
