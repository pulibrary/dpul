require 'rails_helper'

RSpec.describe ExhibitsController, vcr: { cassette_name: "all_collections", allow_playback_repeats: true } do
  before do
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    sign_in FactoryBot.create(:site_admin)
  end
  describe "#create" do
    context "when given just a slug" do
      let(:exhibit) do
        {
          slug: "princeton-best"
        }
      end
      it "works and pulls the title" do
        post :create, params: { exhibit: exhibit }

        expect(response).not_to render_template "new"
        last_exhibit = Spotlight::Exhibit.last
        expect(last_exhibit.title).to eq "princeton"
        expect(last_exhibit.slug).to eq "princeton-best"
      end
    end
    context "when not given a slug" do
      render_views
      let(:exhibit) do
        {
          slug: ""
        }
      end
      it "renders an error" do
        post :create, params: { exhibit: exhibit }

        expect(response).to render_template "new"
        expect(assigns["exhibit"].errors.messages[:slug]).to eq ["can't be blank"]
      end
    end
    context "when given no params" do
      let(:exhibit) do
        {
          tag_list: nil
        }
      end
      it "renders an error" do
        post :create, params: { exhibit: exhibit }

        expect(response).to render_template "new"
        expect(assigns["exhibit"].errors.messages[:slug]).to eq ["can't be blank"]
      end
    end
  end

  describe "#destroy" do
    let(:exhibit) do
      {
        slug: "princeton-best"
      }
    end
    context "when there are resources in the index" do
      it "destroys them from solr" do
        post :create, params: { exhibit: exhibit }

        exhibit = assigns(:exhibit)
        controller.instance_variable_set(:@exhibit, nil)
        delete :destroy, params: { id: exhibit.id }

        expect(solr.get("select", params: { q: "*:*" })["response"]["numFound"]).to eq 0
      end

      def solr
        Blacklight.default_index.connection
      end
    end
  end
end
