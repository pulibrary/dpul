# frozen_string_literal: true

require 'rails_helper'

describe IndexHelper do
  let(:helper) { TestingHelper.new }
  let(:index_presenter) { instance_double('RTLIndexPresenter', class: RTLIndexPresenter) }
  let(:document) do
    {
      title: 'title',
      alternate_title: 'alternate_title'
    }
  end
  before do
    class TestingHelper
      include IndexHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Context
    end
  end
  after do
    Object.send(:remove_const, :TestingHelper)
  end

  describe '#index_masonry_document_label' do
    subject(:output) { helper.index_masonry_document_label(document) }

    let(:label) { 'title' }

    before do
      allow(helper).to receive(:index_presenter).and_return(index_presenter)
      allow(helper).to receive(:document_show_link_field).and_return(:full_title_tesim)
      allow(index_presenter).to receive(:label).and_return(label)
    end

    it 'retrieves the label using the title' do
      expect(output).to eq 'title'
    end

    context 'when multiple titles exist' do
      let(:label) { ['title1', 'title2'] }

      it 'retrieves the label using only the first title' do
        expect(output).to eq 'title1'
      end
    end
  end

  describe '#render_index_document' do
    before do
      allow(helper).to receive(:index_presenter).and_return(index_presenter)
      allow(helper).to receive(:document_show_link_field).and_return(:title)
      allow(helper).to receive(:url_for_document).and_return('link')
      allow(helper).to receive(:document_link_params).and_return({})
      allow(index_presenter).to receive(:label).and_return(label)
    end

    context 'when given a ltr label' do
      let(:label) { 'title' }

      it 'returns a single ltr span tag' do
        tag = helper.render_index_document(document)
        expect(tag).to eq '<span style="display: block;" dir="ltr"><a href="link">title</a></span>'
      end
    end

    context 'when given a rtl label' do
      let(:label) { 'تضيح المقال' }

      it 'returns a single rtl span tag' do
        tag = helper.render_index_document(document)
        expect(tag).to eq '<span style="display: block;" dir="rtl"><a href="link">تضيح المقال</a></span>'
      end
    end

    context 'when given a multivalued title' do
      let(:label) { ['تضيح المقال', 'title'] }

      it 'returns multiple span tags' do
        tag = helper.render_index_document(document)
        expect(tag).to eq '<span style="display: block;" dir="rtl"><a href="link">تضيح المقال</a></span>'\
                          '<span style="display: block;" dir="ltr"><a href="link">title</a></span>'
      end
    end
  end
end
