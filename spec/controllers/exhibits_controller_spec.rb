require 'rails_helper'

RSpec.describe ExhibitsController, vcr: { cassette_name: "all_collections" } do
  before do
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    sign_in FactoryGirl.create(:site_admin)
  end
  describe "#create" do
    context "when given just a slug" do
      let(:params) do
        {
          exhibit: {
            slug: "princeton-best"
          }
        }
      end
      it "works and pulls the title" do
        post :create, params

        expect(response).not_to render_template "new"
        last_exhibit = Spotlight::Exhibit.last
        expect(last_exhibit.title).to eq "princeton"
        expect(last_exhibit.slug).to eq "princeton-best"
      end
    end
  end
end
