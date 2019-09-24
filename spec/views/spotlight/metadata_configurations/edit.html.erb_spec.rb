require 'rails_helper'

describe 'spotlight/metadata_configurations/edit', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  before do
    assign(:exhibit, exhibit)
    assign(:blacklight_configuration, exhibit.blacklight_configuration)
    allow(view).to receive_messages(
      current_exhibit: exhibit,
      blacklight_config: exhibit.blacklight_configuration,
      available_view_fields: { some_view_type: 1, another_view_type: 2 },
      select_deselect_button: nil
    )
    Spotlight::CustomField.create!(exhibit: exhibit, slug: "one", field: "one", label: "one", field_type: "vocab", readonly_field: false)
    Spotlight::CustomField.create!(exhibit: exhibit, slug: "two", field: "two", label: "two", field_type: "vocab", readonly_field: true)
  end

  it "displays only writeable custom fields" do
    render

    within "#exhibit-specific-fields" do
      expect(rendered).to have_content "one"
      expect(rendered).not_to have_content "two"
      expect(rendered).to have_selector "th", text: "Text Area"
    end
  end
end
