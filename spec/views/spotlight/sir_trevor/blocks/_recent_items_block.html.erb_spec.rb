# frozen_string_literal: true

require 'rails_helper'

describe 'spotlight/sir_trevor/blocks/_recent_items_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/recent_items_block.html.erb' }
  let(:block) do
    RecentItemsBlock.new({ type: 'block', data: {} }, view)
  end
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    # Include the search helper so the block can run a scoped query. Normally
    # the view has access to this from the controller, but this test uses an
    # anonymous controller.
    view.class.include Blacklight::SearchHelper
    allow(view).to receive_messages(recent_items_block: block)
    allow(view).to receive_messages(
      blacklight_config: CatalogController.blacklight_config,
      current_exhibit: exhibit,
      search_session: {},
      current_search_session: {}
    )

    FactoryBot.create(
      :iiif_resource,
      url: "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest",
      exhibit: exhibit,
      manifest_fixture: "1r66j1149-expanded.json",
      source_metadata_identifier: "12345678",
      spec: self
    )
    FactoryBot.create(
      :iiif_resource,
      url: "https://hydra-dev.princeton.edu/concern/scanned_resources/44558d29f/manifest",
      exhibit: exhibit,
      manifest_fixture: "44558d29f.json",
      spec: self
    )
  end

  it 'renders a set of recent items' do
    render partial: p, locals: { recent_items_block: block }

    expect(rendered).to have_selector ".card", count: 2
    # Assert first document is the newest indexed one.
    expect(rendered).to have_selector ".card:nth-child(1)", text: "L''ordine dorico ossia il tempio d''Ercole nella città di Cori umiliato alla santita di nostro signore Papa Pio Sesto"
  end
end
