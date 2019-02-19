require 'rails_helper'

describe IIIFResource do
  context "when ingesting a manifest with full text" do
    it "indexes the full text into a TESIM field" do
      url = 'https://figgy.princeton.edu/concern/ephemera_folders/e41da87f-84af-4f50-ab69-781576cf82db/manifest'
      stub_manifest(url: url, fixture: 'full_text_manifest.json')
      stub_metadata(id: "e41da87f-84af-4f50-ab69-781576cf82db")
      stub_ocr_content(id: "e41da87f-84af-4f50-ab69-781576cf82db", text: "More searchable text")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      resource.save
      resource.reindex

      solr = Blacklight.default_index.connection
      solr.commit
      solr_doc = solr.select(q: "*:*")["response"]["docs"].first

      expect(solr_doc["full_text_tesim"]).not_to be_blank
    end
  end
  context "when provided an override title" do
    it "doesn't get overridden" do
      url = 'https://figgy.princeton.edu/concern/ephemera_folders/e41da87f-84af-4f50-ab69-781576cf82db/manifest'
      stub_manifest(url: url, fixture: 'full_text_manifest.json')
      stub_metadata(id: "e41da87f-84af-4f50-ab69-781576cf82db")
      stub_ocr_content(id: "e41da87f-84af-4f50-ab69-781576cf82db", text: "More searchable text")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      resource.save
      resource.reindex
      sidecar = resource.solr_document_sidecars[0]
      sidecar.data["override-title_tesim"] = "Test"
      sidecar.data["override-title_ssim"] = "Test"
      sidecar.save!
      resource = described_class.find(resource.id)
      resource.reindex

      solr = Blacklight.default_index.connection
      solr.commit
      solr_doc = solr.select(q: "*:*")["response"]["docs"].first

      expect(solr_doc["exhibit_exhibit-a_override-title_ssim"]).to eq ["Test"]
    end
  end
  context 'with recorded http interactions' do
    let(:url) { 'https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest' }

    it 'ingests a iiif manifest' do
      stub_manifest(url: url, fixture: '1r66j1149-expanded.json')
      stub_metadata(id: "12345678")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      expect(resource.save).to be true

      solr_doc = nil
      Blacklight.default_index.connection.commit
      resource.document_builder.to_solr { |x| solr_doc = x }
      expect(solr_doc["full_title_tesim"]).to eq ['Christopher and his kind, 1929-1939']
      expect(solr_doc["readonly_created_tesim"]).to eq ["1976-01-01T00:00:00Z"]
      expect(solr_doc["readonly_range-label_tesim"]).to eq ["Chapter 1", "Chapter 2"]
      expect(Spotlight::CustomField.last.field_type).to eq 'vocab'
      expect(solr_doc["readonly_created_ssim"]).to eq ["1976-01-01T00:00:00Z"]
      expect(solr_doc["readonly_description_ssim"]).to eq ["First", "Second"]
    end
    it 'indexes collections' do
      stub_manifest(url: url, fixture: '1r66j1149-expanded.json')
      stub_metadata(id: "12345678")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      expect(resource.save).to be true

      solr_doc = nil
      Blacklight.default_index.connection.commit
      resource.document_builder.to_solr { |x| solr_doc = x }
      expect(solr_doc["readonly_collections_tesim"]).to eq ["East Asian Library Digital Bookshelf"]
    end
    context "when given a MVW" do
      let(:url) { "https://hydra-dev.princeton.edu/concern/multi_volume_works/f4752g76q/manifest" }
      before do
        stub_manifest(url: url, fixture: "mvw.json")
        stub_manifest(
          url: "https://hydra-dev.princeton.edu/concern/scanned_resources/k35694439/manifest",
          fixture: "vol1.json"
        )
        stub_metadata(id: "12345678")
      end

      it "ingests both items as individual solr records, marking the child" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
        resource = described_class.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy

        Blacklight.default_index.connection.commit
        docs = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"]
        expect(docs.length).to eq 2
        scanned_resource_doc = docs.find { |x| x["full_title_tesim"] == ["Scanned Resource 1"] }
        mvw_doc = docs.find { |x| x["full_title_tesim"] == ["MVW", "Second Title"] }
        expect(scanned_resource_doc["collection_id_ssim"]).to eq [mvw_doc["id"]]
        expect(mvw_doc["collection_id_ssim"]).to eq nil
      end
      it "stores the correct full image URL" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
        resource = described_class.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy

        Blacklight.default_index.connection.commit
        docs = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"]
        scanned_resource_doc = docs.find { |x| x["full_title_tesim"] == ["Scanned Resource 1"] }
        expect(scanned_resource_doc["full_image_url_ssm"]).to eq ["https://libimages1.princeton.edu/loris/plum/hq%2F37%2Fvn%2F61%2F6-intermediate_file.jp2/full/!600,600/0/default.jpg"]
      end
    end
    context "when given an unreachable seeAlso url" do
      let(:url) { "https://hydra-dev.princeton.edu/concern/scanned_resources/s9w032300r/manifest" }
      before do
        stub_manifest(url: url, fixture: "s9w032300r.json")
        stub_metadata(id: "12345678", status: 407)
      end

      it "ingests a iiif manifest using the metadata pool, excludes range labels when missing" do
        exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
        resource = described_class.new url: url, exhibit: exhibit
        expect(resource.save_and_index).to be_truthy

        Blacklight.default_index.connection.commit
        docs = Blacklight.default_index.connection.get("select", params: { q: "*:*" })["response"]["docs"]
        scanned_resource_doc = docs.find { |x| x["full_title_tesim"] == ["Christopher and his kind, 1929-1939"] }
        expect(scanned_resource_doc["readonly_date-created_tesim"]).to eq ['1976-01-01T00:00:00Z']
        expect(scanned_resource_doc["readonly_range-label_tesim"]).to eq nil
        expect(scanned_resource_doc["readonly_language_tesim"]).to eq ["English"]
      end
    end

    context "when given JSON-LD for Collections with invalid structure" do
      let(:url) { "https://localhost.localdomain/scanned_resources/s9w032300r/manifest" }
      let(:exhibit) { Spotlight::Exhibit.create(title: 'Exhibit A') }
      let(:resource) { described_class.new(url: url, exhibit: exhibit) }

      let(:scanned_resource_manifest) do
        {
          "@context": "http://iiif.io/api/presentation/2/context.json",
          "@id": "https://localhost.localdomain/scanned_resources/1r66j1149/manifest",
          "@type": "sc:Manifest",
          "description": "First",
          "label": ["Christopher and his kind, 1929-1939"],
          "viewingHint": "individuals",
          "viewingDirection": "left-to-right",
          "service": {
            "@context": "http://iiif.io/api/auth/0/context.json",
            "@id": "https://hydra-dev.princeton.edu/users/auth/cas",
            "label": "Login to Figgy using CAS",
            "profile": "http://iiif.io/api/auth/0/login",
            "service": { "hsh": nil }
          },
          "structures": [
            {
              "@id": "https://hydra-dev.princeton.edu/concern/scanned_resources/s9w032300r/manifest/range/g70237482003920",
              "@type": "sc:Range",
              "label": "Logical",
              "viewingHint": "top",
              "ranges": [
                {
                  "@id": "https://hydra-dev.princeton.edu/concern/scanned_resources/s9w032300r/manifest/range/g70237482056940",
                  "@type": "sc:Range",
                  "label": "Chapter 1",
                  "canvases": [
                    "https://hydra-dev.princeton.edu/concern/scanned_resources/s9w032300r/manifest/canvas/sbn9996723",
                    "https://hydra-dev.princeton.edu/concern/scanned_resources/s9w032300r/manifest/canvas/s9k41zd485"
                  ]
                },
                {
                  "@id": "https://hydra-dev.princeton.edu/concern/scanned_resources/s9w032300r/manifest/range/g70237482036180",
                  "@type": "sc:Range",
                  "label": "Chapter 2",
                  "canvases": [
                    "https://hydra-dev.princeton.edu/concern/scanned_resources/s9w032300r/manifest/canvas/sww72bb48n",
                    "https://hydra-dev.princeton.edu/concern/scanned_resources/s9w032300r/manifest/canvas/sjs956f80z"
                  ]
                }
              ]
            }
          ],
          "metadata": [
            {
              "label": "Date created",
              "value": [{ "@value": "1976" }]
            },
            {
              "label": "Collections",
              "value": [{ "id": { "id": "058c1862-30dc-431c-90b5-4e141282c7a1" }, "internal_resource": "Collection", "created_at": "11/29/17 12:46:50 PM UTC" }]
            }
          ],
          "seeAlso": [
            { "@id": "https://bibdata.princeton.edu/bibliographic/1234567/jsonld", "format": "application/ld+json" },
            { "@id": "bla", "format": "text/xml" }
          ],
          "rendering": { "@id": "http://arks.princeton.edu/ark:88435/7w62fb79g", "format": "text/html" }
        }
      end

      let(:collection_manifest) do
        {
          "@id": "https://localhost.localdomain/collections/2b88qc199/manifest",
          "@type": "sc:Collection",
          "label": "princeton",
          "viewingHint": "individuals",
          "structures": [
            {
              "@id": "https://localhost.localdomain/collections/2b88qc199/manifest/range/g70272079000020",
              "@type": "sc:Range",
              "label": "Logical",
              "viewingHint": "top"
            }
          ],
          "metadata": [
            {
              "label": "Exhibit",
              "value": ["princeton-best"]
            }
          ],
          "manifests": [
            {
              "@id": "https://localhost.localdomain/scanned_resources/1r66j1149/manifest",
              "@type": "sc:Manifest",
              "label": ["Christopher and his kind, 1929-1939"],
              "viewingHint": "individuals",
              "viewingDirection": "left-to-right"
            }
          ]
        }
      end

      let(:collections_manifest) do
        {
          "@context": "http://iiif.io/api/presentation/2/context.json",
          "@id": "https://localhost.localdomain/collections/manifest",
          "@type": "sc:Collection",
          "label": "Figgy Collections",
          "description": "All collections which are a part of Figgy.",
          "viewingHint": "individuals",
          "structures": [
            {
              "@id": "https://localhost.localdomain/collections/manifest/range/g70272257673280",
              "@type": "sc:Range",
              "label": "Logical",
              "viewingHint": "top"
            }
          ],
          "collections": [
            {
              "@id": "https://localhost.localdomain/collections/2b88qc199/manifest",
              "@type": "sc:Collection",
              "label": "princeton",
              "viewingHint": "individuals",
              "structures": [
                {
                  "@id": "https://localhost.localdomain/collections/2b88qc199/manifest/range/g70272079000020",
                  "@type": "sc:Range",
                  "label": "Logical",
                  "viewingHint": "top"
                }
              ],
              "metadata": [
                {
                  "label": "Exhibit",
                  "value": ["princeton-best"]
                }
              ]
            }
          ]
        }
      end

      before do
        stub_request(
          :get,
          "https://localhost.localdomain/scanned_resources/1r66j1149/manifest"
        ).to_return(body: JSON.generate(scanned_resource_manifest))
        stub_request(
          :get,
          "https://localhost.localdomain/collections/2b88qc199/manifest"
        ).to_return(body: JSON.generate(collection_manifest))
        stub_request(
          :get,
          url
        ).to_return(body: JSON.generate(collections_manifest))
        stub_request(
          :head,
          url
        ).to_return(headers: { 'Content-Type' => 'application/json; charset=utf-8' })
      end

      it "raises an error" do
        expect { resource.save }.to raise_error(IIIFResource::InvalidIIIFManifestError, "Invalid Collection metadata found in the IIIF Manifest: #{url}")
      end
    end

    describe '#save_and_index_now' do
      let(:exhibit) { Spotlight::Exhibit.create title: 'Exhibit A' }
      let(:resource) { described_class.new url: url, exhibit: exhibit }

      before do
        allow(Spotlight::ReindexJob).to receive(:perform_now)
        allow(resource).to receive(:save)
      end

      it 'calls perform now on Spotlight::ReindexJob' do
        resource.save_and_index_now
        expect(Spotlight::ReindexJob).to have_received(:perform_now)
      end
    end
  end
end
