require 'rails_helper'

describe IIIFIngestJob do
  let(:url1) { 'http://example.com/1/manifest' }
  let(:url2) { 'http://example.com/2/manifest' }
  let(:exhibit) { Spotlight::Exhibit.new }
  let(:resource) { IIIFResource.new url: nil, exhibit: exhibit }

  before do
    allow(exhibit).to receive(:id).and_return('exhibit1')
    allow(resource).to receive(:save_and_index)
  end

  it 'ingests a single url' do
    expect(IIIFResource).to receive(:new).with(url: url1, exhibit_id: exhibit.id).and_return(resource)

    described_class.new.perform(url1, exhibit)
  end

  it 'ingests each of an array of urls' do
    expect(IIIFResource).to receive(:new).with(url: url1, exhibit_id: exhibit.id).and_return(resource)
    expect(IIIFResource).to receive(:new).with(url: url2, exhibit_id: exhibit.id).and_return(resource)

    described_class.new.perform([url1, url2], exhibit)
  end
end
