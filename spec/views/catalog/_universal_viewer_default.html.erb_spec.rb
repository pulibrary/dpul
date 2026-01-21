# frozen_string_literal: true

require "rails_helper"

describe "catalog/_universal_viewer_default", type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit, condensed_viewer: true) }

  before do
    assign(:exhibit, exhibit)
    assign(:blacklight_configuration, exhibit.blacklight_configuration)
    allow(view).to receive_messages(
      current_exhibit: exhibit,
      blacklight_config: exhibit.blacklight_configuration,
      available_view_fields: { some_view_type: 1, another_view_type: 2 },
      select_deselect_button: nil,
      universal_viewer_url: "https://bla.com/universal"
    )
    render
  end

  context "when the exhibit is configured to have a condensed viewer" do
    it "displays a condensed viewer" do
      expect(rendered).to have_selector ".uv__overlay.condensed"
    end
  end

  context "when the exhibit is configured not to have a condensed viewer" do
    let(:exhibit) { FactoryBot.create(:exhibit, condensed_viewer: false) }

    it "doesn't display a condensed viewer" do
      expect(rendered).to have_selector ".uv__overlay"
      expect(rendered).not_to have_selector ".uv__overlay.condensed"
      expect(rendered).to have_xpath("//iframe[@title]")
    end
  end
end
