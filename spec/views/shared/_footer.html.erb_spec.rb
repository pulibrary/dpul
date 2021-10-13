# frozen_string_literal: true

require 'rails_helper'

describe 'shared/_footer', type: :view do
  it "displays a back to top link", js: true do
    render
    expect(rendered).to have_selector "a.back-to-top"
  end
end
