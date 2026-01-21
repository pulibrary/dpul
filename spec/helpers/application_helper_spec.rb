# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper, type: :helper do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:field) { instance_double(Spotlight::CustomField) }
  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    blacklight_config.index_fields["foo_tesim"] = OpenStruct.new("text_area" => "1")
    allow(field).to receive(:field).and_return("foo_tesim")
    allow(exhibit).to receive_messages(blacklight_config:)
  end

  describe "#text_area?" do
    let(:output) { helper.text_area?(field, exhibit) }

    it "determines whether or not a field should be rendered as a text_area" do
      expect(output).to be true
    end
  end

  describe "#text_area_value" do
    let(:sidecar) { instance_double(Spotlight::SolrDocumentSidecar) }
    let(:output) { helper.text_area_value(field, sidecar) }
    let(:data) do
      [{ type: "text", data: { text: "testing note", format: "html" } }]
    end

    before do
      allow(sidecar).to receive(:data).and_return("foo_tesim" => { data: })
    end

    it "normalizes the text area value" do
      expect(output).to eq(data:)
    end
  end

  describe "#header_title" do
    let(:current_site) { instance_double(Spotlight::Site) }

    before do
      allow(helper).to receive(:current_site).and_return(current_site)
    end

    it "delegates to the site title attribute for the Spotlight::Site" do
      allow(current_site).to receive(:title).and_return("Test Site Title")

      expect(helper.header_title).to eq "Test Site Title"
    end
    context "when the Spotlight::Site title cannot be retrieved" do
      before do
        allow(current_site).to receive(:title).and_return(nil)
      end

      it "accesses the Blacklight application name" do
        expect(helper.header_title).to eq "Digital PUL"
      end
    end
  end

  describe "#application_name" do
    let(:current_site) { instance_double(Spotlight::Site) }

    before do
      allow(helper).to receive(:current_site).and_return(current_site)
      allow(current_site).to receive(:title).and_return("Test Site Title")
    end

    it "delegates to the #application_name for the Spotlight::Site" do
      expect(helper.application_name).to eq "Test Site Title"
      expect(helper.application_name).to eq helper.header_title
    end
  end

  describe "#document_thumbnail" do
    let(:exhibit) { instance_double(Spotlight::Exhibit) }
    let(:document) { instance_double(SolrDocument) }
    let(:thumbnail_url) { "https://images.institution.edu/image-server/prefix/id%2Fintermediate_file.jp2/full/!200,150/0/default.jpg" }
    let(:output) { helper.document_thumbnail(document) }
    let(:manifest) {
      "https://repository.institution.edu/concern/scanned_resources/cfd8cb11-660f-4f12-92f6-fb2b22995028/manifest"
    }

    before do
      allow(helper).to receive(:current_exhibit).and_return(exhibit)
      allow(exhibit).to receive(:thumbnails_enabled).and_return(true)
    end

    context "when document is found" do
      before do
        allow(document).to receive(:fetch).with(:thumbnail_ssim, nil).and_return([thumbnail_url])
        allow(document).to receive(:manifest).and_return(manifest)
      end

      it "generates an <img> element for SolrDocument thumbnails when Exhibits are configured to display them" do
        assign(:document, document)
        expect(output).to eq("<img src=\"#{thumbnail_url}\" />")
      end

      it "generates an <img> element even when @document is not assigned" do
        assign(:document, nil)
        expect(output).to eq("<img src=\"#{thumbnail_url}\" />")
      end
    end

    context "when the document cannot be retrieved" do
      let(:document) { nil }

      it "does not generate any markup" do
        expect(output).to be nil
      end
    end

    context "when thumbnails are disabled for the exhibit" do
      before do
        allow(exhibit).to receive(:thumbnails_enabled).and_return(false)
      end

      it "suppresses the thumbnails and does not generate markup" do
        expect(output).to be nil
      end
    end
  end

  describe "#universal_viewer_url" do
    let(:document) { instance_double(SolrDocument) }
    let(:manifest_url) { "https://figgy.princeton.edu/concern/scanned_resources/c321a5f1-26e4-46ec-9a19-7c3351eaf308/manifest" }
    let(:config_url) { "https://figgy.princeton.edu/viewer/exhibit/config?manifest=#{manifest_url}" }

    before do
      allow(document).to receive(:manifest).and_return(manifest_url)
      assign(:document, document)
    end

    it "generates the URL for an embedded installation of the Universal Viewer" do
      expect(helper.universal_viewer_url).to eq "https://figgy.princeton.edu/viewer#?manifest=#{CGI.escape(manifest_url)}&config=#{CGI.escape(config_url)}"
    end
  end
end
