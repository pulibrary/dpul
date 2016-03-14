require 'rails_helper'

RSpec.describe "catalog/_show_default.html.erb" do
  let(:document) do
    SolrDocument.new(id: "1",
                     author_ssim: ["The Doctor"],
                     publisher_ssim: ["The Byzantium", "The Silence"])
  end
  before do
    allow(view).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
    render "catalog/show_default", document: document
  end
  it "renders all possible metadata fields" do
    expect(rendered).to have_content "The Doctor"
    expect(rendered).to have_content "The Byzantium, The Silence"
  end
end
