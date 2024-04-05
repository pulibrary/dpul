# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Locale Selector', js: true do
  with_queue_adapter :inline
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:language_es) { FactoryBot.create(:language, exhibit:, locale: 'es', public: true) }

  before { login_as user }

  describe 'switching locales' do
    let(:user) { FactoryBot.create(:exhibit_visitor) }

    it 'switches back to English when returning to "Digital PUL"' do
      visit "/slug-1/home?locale=es"

      expect(page).not_to have_css('input[placeholder="Search..."]')
      expect(page).to have_css('input[placeholder="Buscar..."]')

      find("a[title='Digital PUL']").click

      expect(page).to have_css('input[placeholder="Search..."]')
      expect(page).not_to have_css('input[placeholder="Buscar..."]')
    end
  end
end
