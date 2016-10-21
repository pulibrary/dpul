require 'rails_helper'

RSpec.describe RTLIndexPresenter do
  subject(:presenter) { described_class.new(document, double(blacklight_config: blacklight_config)) }

  let(:document) do
    {
      title: title,
      alternate_title: alternate_title
    }
  end
  let(:title) { ['تضيح المقال'] }
  let(:alternate_title) { ['a different title'] }
  let(:index_config) { double(title_field: 'title', display_title_field: '') }
  let(:field_config) { double }
  let(:blacklight_config) do
    double(
      index: index_config,
      index_fields: { field: field_config }
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
    end

    context 'when configured with a display title field' do
      let(:index_config) { double(title_field: 'title', display_title_field: 'alternate_title') }

      it 'renders the display title field' do
        expect(presenter.label(:title)).to eq 'a different title'
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
