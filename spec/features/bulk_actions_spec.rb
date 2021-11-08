# frozen_string_literal: true

require 'rails_helper'

describe 'Bulk actions', type: :feature, js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

  before do
    sign_in admin
    d = SolrDocument.new(id: 'dq287tq6352')
    exhibit.tag(d.sidecar(exhibit), with: ['foo'], on: :tags)
    d.make_private! exhibit
    d.reindex
    Blacklight.default_index.connection.commit
  end

  it 'adding tags', js: true do
    visit spotlight.search_exhibit_catalog_path(exhibit, q: 'dq287tq6352')

    click_button 'Bulk actions'
    click_link 'Add tags'
    expect(page).to have_css 'h4', text: 'Add tags', visible: true
    within '#add-tags-modal' do
      find('[data-autocomplete-fetched="true"]', visible: false)
      find('.tt-input').set('good,stuff')
    end
    accept_confirm 'All items in the result set will be updated. Are you sure?' do
      click_button 'Add'
    end
    expect(page).to have_css '.alert', text: 'Tags are being added for 1 item.'
    expect(SolrDocument.new(id: 'dq287tq6352').sidecar(exhibit).all_tags_list).to include('foo', 'good', 'stuff')
  end

  it "complies with WCAG" do
    pending("fix accessibility violations")
    visit spotlight.search_exhibit_catalog_path(exhibit, q: 'dq287tq6352')
    expect(page).to be_axe_clean
      .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
      .excluding(".tt-hint") # Issue is in typeahead.js library
  end
end
