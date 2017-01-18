require 'rails_helper'

describe 'spotlight/metadata_configurations/edit', type: :view do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  before do
    assign(:exhibit, exhibit)
    assign(:blacklight_configuration, exhibit.blacklight_configuration)
    allow(view).to receive_messages(
      current_exhibit: exhibit,
      blacklight_config: exhibit.blacklight_configuration,
      available_view_fields: { some_view_type: 1, another_view_type: 2 },
      select_deselect_button: nil,
      configuration_page_title: "test",
      exhibit_edit_link: "edit",
      exhibit_delete_link: "delete",
      exhibit_create_link: "create"
    )
    Spotlight::CustomField.create!(exhibit: exhibit, slug: "one", field: "one", label: "one", field_type: "vocab", readonly_field: false)
    Spotlight::CustomField.create!(exhibit: exhibit, slug: "two", field: "two", label: "two", field_type: "vocab", readonly_field: true)
  end

  it "displays only writeable custom fields" do
    render

    expect(rendered).to have_content "one"
    expect(rendered).not_to have_content "two"
  end
end