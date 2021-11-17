# frozen_string_literal: true

require 'rails_helper'

describe IIIFResource do
  with_queue_adapter :inline
  context "when indexing a Recording IIIF v3 manifest" do
    it "indexes succesfully" do
      url = 'https://figgy-staging.princeton.edu/concern/scanned_resources/ea3a706e-dd01-478c-a428-2ef99762e392/manifest'
      stub_manifest(url: url, fixture: 'recording_manifest.json')
      stub_metadata(id: "ea3a706e-dd01-478c-a428-2ef99762e392")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      resource.save
      resource.reindex

      solr = Blacklight.default_index.connection
      solr.commit
      solr_doc = solr.select(q: "*:*")["response"]["docs"].first

      expect(solr_doc["full_title_tesim"]).to eq ['Concert, 2001, October 19 and 20']
      expect(solr_doc["sort_date_ssi"]).not_to be_blank
    end
  end

  context "when indexing a NetID only Recording IIIF v3 manifest" do
    it "uses an auth token if configured" do
      allow(Pomegranate.config).to receive(:[]).and_call_original
      allow(Pomegranate.config).to receive(:[]).with("manifest_authorization_token").and_return("123456")
      url = 'https://figgy-staging.princeton.edu/concern/scanned_resources/ea3a706e-dd01-478c-a428-2ef99762e392/manifest'
      # Stub with the auth token - webmock will error if that's not the request we
      # sent.
      stub_manifest(url: "#{url}?auth_token=123456", fixture: 'recording_manifest.json')
      stub_metadata(id: "ea3a706e-dd01-478c-a428-2ef99762e392", auth_token: "123456")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      resource.save
      resource.reindex

      solr = Blacklight.default_index.connection
      solr.commit
      solr_doc = solr.select(q: "*:*")["response"]["docs"].first

      expect(solr_doc["full_title_tesim"]).to eq ['Concert, 2001, October 19 and 20']
      expect(solr_doc["sort_date_ssi"]).not_to be_blank
      expect(solr_doc["readonly_electronic-locations_ssim"]).to eq ["<a href='http://lib-dbserver.princeton.edu/music/programs/2015-04-24-25.pdf'>Program.</a>"]
    end
  end

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

  context "when ingesting a manifest with a system_created_at/updated_at" do
    let(:url) { 'https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest' }

    it "indexes it into a system_created_at_ssi and makes no CustomField" do
      stub_manifest(url: url, fixture: '1r66j1149-expanded.json')
      stub_metadata(id: "12345678")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      expect(resource.save).to be true

      solr_doc = resource.solr_documents.first
      Blacklight.default_index.connection.commit
      expect(exhibit.custom_fields.where(slug: "system-created-at").size).to eq 0
      expect(exhibit.custom_fields.where(slug: "system-updated-at").size).to eq 0
      expect(solr_doc["readonly_system-created-at_ssim"]).to be_nil
      expect(solr_doc["system_created_at_dtsi"]).to eq "2019-01-01T00:00:00Z"
      expect(solr_doc["system_updated_at_dtsi"]).to eq "2019-01-02T00:00:00Z"
    end
  end

  context "when ingesting a resource with actor groupings" do
    it "indexes all the values" do
      url = 'https://figgy.princeton.edu/concern/scanned_resources/e9f4cdc7-173d-4bc8-befe-f786de455f11/manifest'
      stub_manifest(url: url, fixture: 'actor_groupings.json')
      stub_metadata(id: "e9f4cdc7-173d-4bc8-befe-f786de455f11")

      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      resource.save_and_index

      solr = Blacklight.default_index.connection
      solr.commit
      solr_doc = solr.select(q: "*:*")["response"]["docs"].first
      expect(solr_doc["readonly_actor_ssim"]).to eq ["Milījī, Maḥmūd, محمود المليجي", "هدى سلطان"]
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

  context "when there's an existing broken Spotlight::CustomField Override Title" do
    let(:url) { 'https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest' }
    it "doesn't make another" do
      stub_manifest(url: url, fixture: '1r66j1149-expanded.json')
      stub_metadata(id: "12345678")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      resource.save_and_index
      Spotlight::CustomField.create(exhibit: exhibit, field: "override-title_ssim", label: "Override Title", slug: "override-title_ssim")

      custom_field_count = Spotlight::CustomField.all.size

      5.times { resource.reload.save_and_index }
      expect(Spotlight::CustomField.all.size).to eq custom_field_count
    end
  end

  context "when re-indexing an existing resource" do
    let(:url) { 'https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest' }

    it "doesn't create duplicate custom fields" do
      stub_manifest(url: url, fixture: '1r66j1149-expanded.json')
      stub_metadata(id: "12345678")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      resource.save_and_index

      custom_field_count = Spotlight::CustomField.all.size
      custom_field = Spotlight::CustomField.where(slug: "call-number").first
      custom_field.exhibit.blacklight_configuration.index_fields = { custom_field.field => { "label" => "Test Label" } }
      custom_field.exhibit.save

      10.times { resource.reload.save_and_index }
      expect(Spotlight::CustomField.all.size).to eq custom_field_count
    end
  end

  context 'with recorded http interactions' do
    let(:url) { 'https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest' }

    it 'ingests a iiif manifest with metadata from jsonld' do
      stub_manifest(url: url, fixture: '1r66j1149-expanded.json')
      stub_metadata(id: "12345678")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      expect(resource.save).to be true

      Blacklight.default_index.connection.commit
      solr_doc = resource.solr_documents.first
      expect(solr_doc["full_title_tesim"]).to eq ['Christopher and his kind, 1929-1939']
      expect(solr_doc["readonly_created_tesim"]).to eq ["1976-01-01T00:00:00Z"]
      expect(solr_doc["readonly_range-label_tesim"]).to eq ["Chapter 1", "Chapter 2"]
      expect(Spotlight::CustomField.last.field_type).to eq 'vocab'
      expect(solr_doc["readonly_created_ssim"]).to eq ["1976-01-01T00:00:00Z"]
      expect(solr_doc["readonly_description_ssim"]).to eq ["First", "Second"]
      expect(solr_doc["readonly_description_ssim"]).to eq ["First", "Second"]
      expect(solr_doc["readonly_view-in-catalog_ssim"]).to eq ["<a href='https://catalog.princeton.edu/12345678'>https://catalog.princeton.edu/12345678</a>"]
    end

    it "ingests finding aids metadata dates" do
      stub_manifest(url: url, fixture: '1r66j1149-expanded.json')
      stub_metadata(id: "12345678", fixture: "findingaids-date")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      expect(resource.save).to be true

      Blacklight.default_index.connection.commit
      solr_doc = resource.solr_documents.first
      expect(solr_doc["sort_date_ssi"]).to eq "1936"
    end

    it "removes old metadata" do
      stub_manifest(url: url, fixture: '1r66j1149-expanded.json')
      # Stub metadata with a record which has a creator
      stub_metadata(id: "12345678")

      # Index record with creator.
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      resource.save_and_index

      # Stub metadata with a record which has no creator and reindex.
      stub_metadata(id: "12345678", fixture: "12345678-changed")
      resource = described_class.find(resource.id)
      resource.save_and_index

      Blacklight.default_index.connection.commit
      solr_doc = resource.solr_documents.first
      solr_doc = SolrDocument.find(solr_doc[:id])
      # Ensure SolrDocument atomic index happens, so it takes into account any
      # potentially stale metadata.
      solr_doc.reindex
      solr_doc = SolrDocument.find(solr_doc[:id])

      expect(solr_doc["readonly_creator_tesim"]).to eq nil
    end

    it 'indexes collections' do
      stub_manifest(url: url, fixture: '1r66j1149-expanded.json')
      stub_metadata(id: "12345678")
      exhibit = Spotlight::Exhibit.create title: 'Exhibit A'
      resource = described_class.new url: url, exhibit: exhibit
      expect(resource.save).to be true

      Blacklight.default_index.connection.commit
      solr_doc = resource.solr_documents.first
      expect(solr_doc["readonly_collections_tesim"]).to eq ["East Asian Library Digital Bookshelf"]
    end

    context 'with a finding aid object' do
      let(:id) { '82177270-5bbe-466a-85e1-e988a0f7a4f0' }
      let(:url) { "https://figgy.princeton.edu/concern/scanned_resources/#{id}/manifest" }

      it 'ingests a link to the finding aid' do
        stub_manifest(url: url, fixture: 'archival_resource.json')
        stub_metadata(id: id)
        stub_ocr_content(id: id, text: "text")
        exhibit = Spotlight::Exhibit.create title: 'Archival Exhibit'
        resource = described_class.new url: url, exhibit: exhibit
        expect(resource.save).to be true

        solr_doc = resource.solr_documents.first
        Blacklight.default_index.connection.commit
        expect(solr_doc["readonly_view-in-finding-aid_ssim"]).to eq ["<a href='https://findingaids.princeton.edu/collections/MC051/c05105'>https://findingaids.princeton.edu/collections/MC051/c05105</a>"]
      end
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

    describe '#reindex' do
      let(:exhibit) { Spotlight::Exhibit.create title: 'Exhibit A' }
      let(:resource) { described_class.new url: url, exhibit: exhibit }
      let(:blacklight_solr) { instance_double(RSolr::Client) }
      let(:data) { resource.solr_documents }

      before do
        stub_manifest(
          url: url,
          fixture: "vol1.json"
        )
        allow(blacklight_solr).to receive(:update)
        allow(blacklight_solr).to receive(:commit)
        resource.reindex
      end

      # JSON-serialization does not preserve the order of properties, so this
      # cannot be tested
      it 'reindexes by calling a solr loader' do
        allow_any_instance_of(Spotlight::Etl::SolrLoader).to receive(:blacklight_solr).and_return(blacklight_solr)
        resource.reindex
        expect(blacklight_solr).to have_received(:update).with(
          hash_including(headers: { 'Content-Type' => 'application/json' })
        )
      end

      context 'when a Solr error is encountered' do
        let(:request) { double }
        let(:response) { double }
        let(:rsolr_error) { RSolr::Error::Http.new(request, response) }

        before do
          allow(rsolr_error).to receive(:to_s).and_return("solr mad")
        end

        it 'logs an error' do
          # Save it first to ensure the noid is in place to be reported
          resource.save_and_index

          allow_any_instance_of(Spotlight::Etl::SolrLoader).to receive(:blacklight_solr).and_return(blacklight_solr)
          allow(blacklight_solr).to receive(:update).and_raise(rsolr_error)
          resource.save_and_index_now

          expect(Spotlight::JobTracker.last.events.where(type: "error").first.data[:message]).to eq "solr mad"
        end
      end
    end

    describe "#reindex" do
      context 'when the resource has a search service' do
        let(:exhibit) { Spotlight::Exhibit.create title: 'Exhibit A' }
        let(:resource) { described_class.new url: url, exhibit: exhibit }
        let(:id) { "c7f0bb99-3721-4171-8a84-0256941e8298" }
        let(:url) { "https://figgy.princeton.edu/concern/scanned_resources/#{id}/manifest" }

        before do
          stub_manifest(url: url, fixture: "search_service.json")
          stub_metadata(id: id)
          stub_ocr_content(id: id, text: "text")
        end

        it 'indexes successfully' do
          expect { resource.reindex }.not_to raise_error
        end
      end
    end
  end
end
