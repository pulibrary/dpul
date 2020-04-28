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

    # Modified Date is 1976-01-03; has thumbnail
    FactoryBot.create(
      :iiif_resource,
      url: "https://hydra-dev.princeton.edu/concern/scanned_resources/e41da87f-84af-4f50-ab69-781576cf82db/manifest",
      exhibit: exhibit,
      manifest_fixture: "full_text_manifest.json",
      figgy_uuid: "e41da87f-84af-4f50-ab69-781576cf82db",
      stubbed_ocr_content: "More searchable text",
      spec: self
    )
    # Modified Date is in 1975; has thumbnail
    FactoryBot.create(
      :iiif_resource,
      url: "https://figgy-staging.princeton.edu/concern/scanned_maps/fffdaa09-b0c6-4ba3-8fe5-de6b13bd3d5f/manifest",
      exhibit: exhibit,
      manifest_fixture: "map.json",
      figgy_uuid: "fffdaa09-b0c6-4ba3-8fe5-de6b13bd3d5f",
      spec: self
    )
    # Modified Date isn't defined; has thumbnail
    FactoryBot.create(
      :iiif_resource,
      url: "https://hydra-dev.princeton.edu/concern/scanned_resources/44558d29f/manifest",
      exhibit: exhibit,
      manifest_fixture: "44558d29f.json",
      spec: self
    )
    # Modified Date is in 1975; no thumbnail
    FactoryBot.create(
      :iiif_resource,
      url: "https://figgy.princeton.edu/concern/scanned_resources/965238bf-7850-4ae2-8830-f709c0f1b732/manifest",
      exhibit: exhibit,
      manifest_fixture: "no_thumbnail.json",
      figgy_uuid: "965238bf-7850-4ae2-8830-f709c0f1b732",
      spec: self
    )
  end

  it 'renders a set of recent items that have thunbnails' do
    render partial: p, locals: { recent_items_block: block }

    expect(rendered).to have_selector ".card", count: 3
    # Assert first document is the most recently modified one.
    expect(rendered).to have_selector ".card:nth-child(1)", text: "Derechos y Democracia: Centro Internacional de Derechos Humanos y Desarrollo Democrático."
  end
end
