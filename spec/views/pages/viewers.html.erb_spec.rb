# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "pages/viewers.html.erb" do
  describe "iiif drag and drop" do
    let(:request_url) { "http://example.com/viewers?manifest=abc" }

    before do
      allow(view).to receive(:request_url).and_return(request_url)
      render
    end

    it "includes a iiif manifest link" do
      expect(response).to have_link("IIIF", href: request_url)
    end
  end
end
