# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RTLIndexPresenter do
  subject(:presenter) { described_class.new(document, double(blacklight_config:, action_name: "index", controller_name: "catalog")) }

  let(:document) do
    {
      title:,
      alternate_title:
    }
  end
  let(:title) { ['تضيح المقال'] }
  let(:alternate_title) { ['a different title'] }
  let(:index_config) { double(title_field: 'title', display_title_field: '') }
  let(:field_config) { double }
  let(:blacklight_config) do
    double(
      index: index_config,
      index_fields: { field: field_config },
      facet_fields: { "exhibit_tags" => double(field: "tags_ssim") }
    )
  end

  before do
    allow(field_config).to receive(:to_h).and_return({})
  end

  describe '#label' do
    context 'when given a single-valued title' do
      it 'renders as a String' do
        expect(presenter.label(:title)).to eq 'تضيح المقال'
      end
    end

    context 'when given a multivalued title' do
      let(:title) { ['تضيح المقال', 'Tawḍīḥ al-maqāl'] }

      it 'renders as an Array' do
        expect(presenter.label(:title)).to match_array ['تضيح المقال', 'Tawḍīḥ al-maqāl']
      end

      it 'renders heading as multiline' do
        exhibit = FactoryBot.create(:exhibit)
        presenter = described_class.new(
          SolrDocument.new(full_title_tesim: title),
          double(document_index_view_type: :current_view, should_render_field?: true, action_name: "index", controller_name: "catalog"),
          exhibit.blacklight_config
        )
        expect(presenter.heading).to eq '<ul><li dir="rtl">تضيح المقال</li><li dir="ltr">Tawḍīḥ al-maqāl</li></ul>'
      end
    end

    context "when given a title with special characters" do
      let(:title) { ["Traité sur l'art de la charpente : théorique et pratique"] }

      it "renders appropriately" do
        expect(presenter.label(:title)).to eq "Traité sur l'art de la charpente : théorique et pratique"
      end
    end

    context 'when configured with a display title field' do
      let(:index_config) { double(title_field: 'title', display_title_field: 'alternate_title') }

      it 'renders the display title field' do
        expect(presenter.label(:title)).to eq 'a different title'
      end
    end

    context 'when an override field exists' do
      it 'renders it' do
        exhibit = FactoryBot.create(:exhibit)
        presenter = described_class.new(
          SolrDocument.new(full_title_tesim: title, "exhibit_test_override-title_ssim": ["Test"], "exhibit_test_public_bsi": false),
          double(document_index_view_type: :current_view, should_render_field?: true, action_name: "index", controller_name: "catalog"),
          exhibit.blacklight_config
        )
        expect(presenter.heading).to eq '<ul><li dir="ltr">Test</li></ul>'
      end
    end

    context "when there's a blank override title" do
      it "uses the default title" do
        exhibit = FactoryBot.create(:exhibit)
        presenter = described_class.new(
          SolrDocument.new(full_title_tesim: title, "exhibit_test_override-title_ssim": [""], "exhibit_test_public_bsi": false),
          double(document_index_view_type: :current_view, should_render_field?: true, action_name: "index", controller_name: "catalog"),
          exhibit.blacklight_config
        )
        expect(presenter.heading).to eq "<ul><li dir=\"rtl\">#{title.first}</li></ul>"
      end
    end

    context 'when passed a string' do
      it 'renders the string as the label' do
        label_value = 'a string'
        expect(presenter.label(label_value)).to eq 'a string'
      end
    end

    context 'when passed a proc' do
      it 'calls the proc' do
        label_value = proc { 'a string' }
        expect(presenter.label(label_value)).to eq 'a string'
      end
    end
  end
end
