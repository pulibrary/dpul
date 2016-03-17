require 'rails_helper'

RSpec.describe ExhibitsController, vcr: { cassette_name: "all_collections", allow_playback_repeats: true } do
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
    context "when not given a slug" do
      let(:params) do
        {
          exhibit: {
            slug: ""
          }
        }
      end
      it "renders an error" do
        post :create, params

        expect(response).to render_template "new"
        expect(assigns["exhibit"].errors.messages[:slug]).to eq ["can't be blank"]
      end
    end
  end
end
