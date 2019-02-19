require 'rails_helper'

RSpec.describe "spotlight/exhibits/_new_exhibit_form.html.erb" do
  before do
    stub_collections(fixture: "collections.json")
  end

  it "displays a select of all available exhibits" do
    assign(:exhibit, Spotlight::Exhibit.new)
    render

    expect(rendered).to have_select("Figgy Collection", options: ['princeton', 'Test Collection 2'])
  end
  it "doesn't display exhibits which are already created" do
    FactoryBot.create(:exhibit, slug: "princeton-best")
    assign(:exhibit, Spotlight::Exhibit.new)
    render

    expect(rendered).to have_select("Figgy Collection", options: ['Test Collection 2'])
  end
  it "posts to the correct place" do
    assign(:exhibit, Spotlight::Exhibit.new)
    render

    expect(rendered).to have_selector "form[action='/']"
  end
end
