# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExhibitsController do
  before do
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    sign_in FactoryBot.create(:site_admin)
    stub_collections(fixture: "collections.json")
    stub_manifest(url: "https://hydra-dev.princeton.edu/collections/2b88qc199/manifest", fixture: "2b88qc199.json")
    stub_manifest(url: "https://hydra-dev.princeton.edu/concern/scanned_resources/1r66j1149/manifest", fixture: "1r66j1149.json")
    stub_metadata(id: "1234567")
    stub_manifest(url: "https://hydra-dev.princeton.edu/concern/scanned_resources/44558d29f/manifest", fixture: "44558d29f.json")
  end

  describe "#create" do
    context "when given just a slug" do
      let(:exhibit) do
        {
          slug: "princeton-best"
        }
      end
      it "works and pulls the title" do
        post :create, params: { exhibit: }

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
        post :create, params: { exhibit: }

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
        post :create, params: { exhibit: }

        expect(response).to render_template "new"
        expect(assigns["exhibit"].errors.messages[:slug]).to eq ["can't be blank"]
      end
    end
  end

  describe '#update' do
    let(:exhibit) { Spotlight::Exhibit.new(title: 'New Collection', published: true, slug: 'new-collection') }
    let(:params) do
      {
        title: 'Some Title',
        thumbnails_enabled: false,
        tag_list: '2014, R. Buckminster Fuller',
        condensed_viewer: true
      }
    end

    before do
      exhibit.save
    end

    it 'disables the rendering of thumbnails and condenses the viewer' do
      exhibit.reload
      expect(exhibit.thumbnails_enabled).to be true
      expect(exhibit.condensed_viewer).to be false
      patch :update, params: { id: exhibit, exhibit: params }

      expect(exhibit.reload.thumbnails_enabled).to be false
      expect(exhibit.condensed_viewer).to be true
      expect(response).to redirect_to "/#{exhibit.slug}/edit"
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
        post :create, params: { exhibit: }

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
