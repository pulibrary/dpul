# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'spotlight/metadata_configurations/_metadata_field', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:p) { 'spotlight/metadata_configurations/metadata_field' }
  before do
    assign(:exhibit, exhibit)
    assign(:blacklight_configuration, exhibit.blacklight_configuration)
    allow(view).to receive_messages(
      current_exhibit: exhibit,
      blacklight_config: exhibit.blacklight_configuration,
      available_view_fields: { some_view_type: 1, another_view_type: 2 },
      select_deselect_button: nil
    )
  end

  let(:facet_field) { exhibit.blacklight_configuration.blacklight_config.index_fields["two"] }
  let(:builder) { ActionView::Helpers::FormBuilder.new 'z', nil, view, {} }

  it 'renders a tooltip for imported fields' do
    Spotlight::CustomField.create!(exhibit:, slug: "two", field: "two", label: "two", field_type: "vocab", readonly_field: true)
    allow(view).to receive(:index_field_label).with(nil, 'two').and_return 'Some label'
    render partial: p, locals: { key: 'two', config: facet_field, f: builder }

    expect(rendered).to have_selector '.import-tooltip'
  end

  it "doesn't render a tooltip for writeable fields" do
    Spotlight::CustomField.create!(exhibit:, slug: "two", field: "two", label: "two", field_type: "vocab", readonly_field: false)
    allow(view).to receive(:index_field_label).with(nil, 'two').and_return 'Some label'
    render partial: p, locals: { key: 'two', config: facet_field, f: builder }

    expect(rendered).not_to have_selector '.import-tooltip'
  end

  it "renders a field to set link_to_facet" do
    Spotlight::CustomField.create!(exhibit:, slug: "two", field: "two", label: "two", field_type: "vocab", readonly_field: false)
    allow(view).to receive(:index_field_label).with(nil, 'two').and_return 'Some label'
    render partial: p, locals: { key: 'two', config: facet_field, f: builder }

    expect(rendered).to have_selector "input[type=checkbox][name='z[two][link_to_facet]'][value='two']"
  end
end
