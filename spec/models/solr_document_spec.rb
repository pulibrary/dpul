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
end
