# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject(:ability) { described_class.new(current_user) }

  let(:exhibit_admin) { FactoryBot.create(:exhibit_admin) }
  let(:current_user) { exhibit_admin }

  describe "featured image" do
    it "can be created by anyone with a role" do
      expect(ability).to be_able_to(:create, Spotlight::FeaturedImage)
    end
  end
end
