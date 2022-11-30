# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookmarksController do
  with_queue_adapter :inline
  describe "#csv" do
    # test expectations
    let(:headers) { "ID,Title,Creator,Date,Subject,Coverage,Location,Language" }
    let(:data1) { ["ww72bb58v", "Plan de Paris : commencé de l'année 1734", "Bretez, Louis, -1738", "1739", "Paris (France)—Aerial views—Early works to 1800", "France", "SAX Oversize G5834.P3A3 1739 .B6e; SAX Electronic Resource; SAX D Alcove 04-05 [atop]; ELF1 Oversize G5834.P3A3 1739 .B6e; ELF1 Electronic Resource; ELF1 D Alcove 04-05 [atop]; MAP Oversize G5834.P3A3 1739 .B6e; MAP Electronic Resource; MAP D Alcove 04-05 [atop]", "French"] }
    let(:data2) { ["nk322j018", "磧砂大藏經 : 六千三百六十二卷; Qisha Da zang jing : liu qian san bai liu shi er juan", "", "1231-1322", "Buddhism—Sacred books", "", "HSVE TC513/2198", "Chinese"] }
    let(:bad_value) { "Plan de Paris : commencé de l'année 1734 / dessiné et gravé sous les ordres de Messire Michel Etienne Turgot, Marquis de Sousmons ... [et al.] ; levé et dessiné par Louis Bretez ; gravé par Claude Lucas ; et écrit par Aubin." }

    before do
      exhibit = FactoryBot.create(:exhibit, title: "Assorted items", slug: "assorted-items")
      admin = FactoryBot.create(:exhibit_admin, exhibit:)
      sign_in admin

      iiif_resource = FactoryBot.create(
        :iiif_resource,
        url: "https://figgy.princeton.edu/concern/scanned_resources/beaec815-6a34-4519-8ce8-40a89d3b1956/manifest",
        exhibit:,
        manifest_fixture: "paris_map.json",
        figgy_uuid: "beaec815-6a34-4519-8ce8-40a89d3b1956",
        spec: self
      )

      iiif_resource2 = FactoryBot.create(
        :iiif_resource,
        url: "https://figgy.princeton.edu/concern/scanned_resources/0cc43bdb-ae21-47b2-90bc-bc21a18ee821/manifest",
        exhibit:,
        manifest_fixture: "chinese_medicine.json",
        figgy_uuid: "0cc43bdb-ae21-47b2-90bc-bc21a18ee821",
        spec: self
      )

      document_id = iiif_resource.solr_documents.first[:id]
      document_id2 = iiif_resource2.solr_documents.first[:id]

      admin.bookmarks.create!([{ document_id:, document_type: "SolrDocument" }])
      admin.bookmarks.create!([{ document_id: document_id2, document_type: "SolrDocument" }])
    end

    it "renders a CSV list of metadata" do
      get :csv

      body = response.body.force_encoding("UTF-8")

      expect(assigns(:documents).length).to eq 2
      expect(body).to include(headers)
      data1.concat(data2).each do |value|
        expect(body).to include(value)
      end

      expect(body).not_to include(bad_value)
    end
  end
end
