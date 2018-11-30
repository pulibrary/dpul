require 'rails_helper'

describe Pomegranate::MetadataConfigurationsController, type: :controller do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

  before { sign_in user }

  describe 'PATCH update' do
    it 'updates metadata fields' do
      blacklight_config = Blacklight::Configuration.new
      blacklight_config.add_index_field %w[a b c d e f]
      allow(CatalogController).to receive_messages(blacklight_config: blacklight_config)
      patch :update, params: {
        exhibit_id: exhibit,
        blacklight_configuration: {
          index_fields: {
            c: { enabled: true, show: true, text_area: "0" },
            d: { enabled: true, show: true, text_area: "0" },
            e: { enabled: true, list: true, text_area: "0" },
            f: { enabled: true, list: true, text_area: "1" }
          }
        }
      }

      assigns[:exhibit].tap do |saved|
        expect(saved.blacklight_configuration.index_fields).to include 'c', 'd', 'e', 'f'
        expect(saved.blacklight_configuration.index_fields['c']).to include text_area: "0"
        expect(saved.blacklight_configuration.index_fields['d']).to include text_area: "0"
        expect(saved.blacklight_configuration.index_fields['e']).to include text_area: "0"
        expect(saved.blacklight_configuration.index_fields['f']).to include text_area: "1"
      end
    end
  end
end
