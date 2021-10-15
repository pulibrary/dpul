# frozen_string_literal: true

require 'rails_helper'

describe SpotlightHelper do
  let(:helper) { TestingHelper.new }
  before do
    class TestingHelper
      include SpotlightHelper
      include ActionView::Helpers::TagHelper
    end
  end

  after do
    Object.send(:remove_const, :TestingHelper)
  end

  describe '#render_document_heading' do
    let(:presenter) { instance_double('RTLShowPresenter', class: RTLShowPresenter) }

    before do
      allow(helper).to receive(:presenter).and_return(presenter)
      allow(presenter).to receive(:heading).and_return('title')
    end

    it 'returns a single ltr span tag' do
      tag = helper.render_document_heading(title: 'title')
      expect(tag).to eq '<h4 itemprop="name">title</h4>'
    end
  end
end
