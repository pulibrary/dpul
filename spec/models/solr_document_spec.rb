# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument do
  let(:solr_document) { described_class.new(hsh) }
  let(:hsh) do
    {
      "access_identifier_ssim" => "123",
      "content_metadata_iiif_manifest_field_ssi" => "https://figgy.princeton.edu/concern/scanned_resources/c321a5f1-26e4-46ec-9a19-7c3351eaf308/manifest"
    }
  end
  describe "#to_param" do
    it "returns the value of access_identifier_ssim" do
      expect(solr_document.to_param).to eq "123"
    end
  end
  describe "#export_formats" do
    it "does not provide dublin core formats" do
      expect(solr_document.export_formats).not_to include(:oai_dc_xml, :dc_xml)
    end
  end
  describe "#manifest" do
    it "accesses the URL for the IIIF manifest" do
      expect(solr_document.manifest).to eq "https://figgy.princeton.edu/concern/scanned_resources/c321a5f1-26e4-46ec-9a19-7c3351eaf308/manifest"
    end
  end
end
