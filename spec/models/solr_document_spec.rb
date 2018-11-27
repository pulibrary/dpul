require 'rails_helper'

RSpec.describe SolrDocument do
  let(:solr_document) { described_class.new(hsh) }
  let(:hsh) do
    {
      "access_identifier_ssim" => "123"
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
end
