# frozen_string_literal: true

require 'rails_helper'

describe IndexHelper do
  let(:helper) { TestingHelper.new }
  let(:document_presenter) { instance_double('RtlIndexPresenter', class: RtlIndexPresenter) }
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

  describe '#render_index_document_title_heading' do
    before do
      allow(helper).to receive(:document_presenter).and_return(document_presenter)
      allow(helper).to receive(:url_for_document).and_return('link')
      allow(helper).to receive(:document_link_params).and_return({})
      allow(document_presenter).to receive(:heading).and_return(heading)
    end

    context 'when given a ltr heading' do
      let(:heading) { 'title' }

      it 'returns a single ltr span tag' do
        tag = helper.render_index_document_title_heading(document)
        expect(tag).to eq '<span><span dir="ltr"><a href="link">title</a></span></span>'
      end
    end

    context 'when given a rtl heading' do
      let(:heading) { 'تضيح المقال' }

      it 'returns a single rtl span tag' do
        tag = helper.render_index_document_title_heading(document)
        expect(tag).to eq '<span><span dir="rtl"><a href="link">تضيح المقال</a></span></span>'
      end
    end

    context 'when given a multivalued title' do
      let(:heading) { ['تضيح المقال', 'title'] }

      it 'returns multiple span tags' do
        tag = helper.render_index_document_title_heading(document)
        expect(tag).to eq '<span><span dir="rtl"><a href="link">تضيح المقال</a></span></span>'\
                          '<span><span dir="ltr"><a href="link">title</a></span></span>'
      end
    end
  end
end
