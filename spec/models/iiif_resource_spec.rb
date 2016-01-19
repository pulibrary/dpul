require 'rails_helper'

describe IIIFResource do
  context 'with mock http interactions' do
    let(:url) { 'http://example.com/1/manifest' }
    let(:json) { '{
      "@context":"http://iiif.io/api/presentation/2/context.json",
      "@id":"http://example.com/1/manifest",
      "@type":"sc:Manifest",
      "label":"Sample Manifest",
      "thumbnail":{
        "@id":"http://example.com/loris/1.jp2/full/100,/0/default.jpg",
        "service":{
          "@context":"http://iiif.io/api/image/2/context.json",
          "@id":"https://example.com/loris/1.jp2",
          "profile":"http://iiif.io/api/image/2/level2.json" }},
      "metadata":[
        { "label": "Creator", "value": [{ "@value": "Author, Alice, 1954-" }] },
        { "label": "Date created", "value": [{ "@value": "1985" }] }
      ]}'
    }
    let(:updated_json) { '{
      "@context":"http://iiif.io/api/presentation/2/context.json",
      "@id":"http://example.com/1/manifest",
      "@type":"sc:Manifest",
      "label":"Updated Manifest",
      "thumbnail":{
        "@id":"http://example.com/loris/1a.jp2/full/100,/0/default.jpg",
        "service":{
          "@context":"http://iiif.io/api/image/2/context.json",
          "@id":"https://example.com/loris/1a.jp2",
          "profile":"http://iiif.io/api/image/2/level2.json" }},
      "metadata":[
        { "label": "Creator", "value": [{ "@value": "Author, Andrea, 1955-" }] },
        { "label": "Date created", "value": [{ "@value": "1988" }] }
      ]}'
    }
    let(:exhibit) { Spotlight::Exhibit.create title: 'Exhibit A' }

    before do
      allow_any_instance_of(described_class).to receive(:open).with(url).and_return(StringIO.new(json))
    end

    describe '#initialize' do
      it 'loads metadata from the IIIF manifest' do
        resource = described_class.new(manifest_url: url, exhibit: exhibit)
        expect(resource.url).to eq(url)
      end
    end

    describe '#manifest' do
      it 'retrieves and parses an IIIF manifest' do
        resource = described_class.new(manifest_url: url, exhibit: exhibit)
        manifest = resource.manifest
        expect(manifest['@id']).to eq(url)
        expect(manifest['label']).to eq('Sample Manifest')
        expect(manifest['thumbnail']['@id']).to eq('http://example.com/loris/1.jp2/full/100,/0/default.jpg')
      end
    end

    describe '#to_solr' do
      subject { described_class.new(manifest_url: url, exhibit: exhibit) }
      before do
        allow(exhibit).to receive_message_chain(:blacklight_config, :document_model, :resource_type_field).and_return(:spotlight_resource_type_ssim)
      end

      it 'indexes iiif metadata' do
        solr_doc = subject.to_solr
        expect(solr_doc[:full_title_ssim]).to eq('Sample Manifest')
        expect(solr_doc[:thumbnail_ssim]).to eq('http://example.com/loris/1.jp2/full/100,/0/default.jpg')
        expect(solr_doc[:creator_ssim]).to eq(['Author, Alice, 1954-'])
        expect(solr_doc[:date_created_ssim]).to eq(['1985'])
      end
      it "updates metadata when the remote manifest is updated" do
        solr_doc = subject.to_solr
        expect(solr_doc[:full_title_ssim]).to eq('Sample Manifest')
        expect(solr_doc[:thumbnail_ssim]).to eq('http://example.com/loris/1.jp2/full/100,/0/default.jpg')
        expect(solr_doc[:creator_ssim]).to eq(['Author, Alice, 1954-'])
        expect(solr_doc[:date_created_ssim]).to eq(['1985'])

        allow_any_instance_of(described_class).to receive(:open).with(url).and_return(StringIO.new(updated_json))
        subject.instance_variable_set :@manifest, nil
        updated_doc = subject.to_solr
        expect(updated_doc[:full_title_ssim]).to eq('Updated Manifest')
        expect(updated_doc[:thumbnail_ssim]).to eq('http://example.com/loris/1a.jp2/full/100,/0/default.jpg')
        expect(updated_doc[:creator_ssim]).to eq(['Author, Andrea, 1955-'])
        expect(updated_doc[:date_created_ssim]).to eq(['1988'])
      end
    end
  end

  context 'with recorded http interactions', vcr: { cassette_name: 'all_collections' } do
    let(:url) { 'https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest' }
    it 'ingests a iiif manifest' do
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new manifest_url: url, exhibit: exhibit
      expect(resource.save).to be true

      reloaded = described_class.last
      expect(reloaded.url).to eq url
      solr_doc = reloaded.to_solr
      expect(solr_doc[:full_title_ssim]).to eq 'Christopher and his kind, 1929-1939'
      expect(solr_doc[:date_created_ssim]).to eq ['1976']
    end
  end
end
