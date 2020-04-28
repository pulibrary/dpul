# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "pages/robots.text.erb" do
  context "when not in production" do
    before do
      allow(Rails.env).to receive(:production?).and_return(false)
      render
    end

    it "disallows all" do
      expect(response).to include "Disallow: /"
    end
  end

  context "when in production" do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
      render
    end

    it "slows down spiders and disallows indexing anything with a query-string" do
      expect(response).to include "Disallow: /*?"
      expect(response).to include "Crawl-delay: 10"
    end
  end
end
