# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RTLShowPresenter do
  subject(:presenter) { described_class.new(document, view_context) }

  let(:document) do
    SolrDocument.new(
      field: ["بي"],
      special: ["Traité sur l'art de la charpente : théorique et pratique"],
      title: ["بي", "Traité sur l'art de la charpente : théorique et pratique"],
      readonly_collections_ssim: [exhibit.title.to_s]
    )
  end
  let(:view_context) { double(blacklight_config: blacklight_config) }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:cc_config) { CatalogController.new.blacklight_config }
  let(:blacklight_config) do
    double(
      show_fields: {
        field: double(highlight: false, accessor: nil, default: nil, field: "field", text_area: false, helper_method: nil, link_to_search: nil, itemprop: nil, separator_options: nil, :separator_options= => nil)
      },
      view_config: double(title_field: "title", html_title_field: nil),
      facet_fields: { "exhibit_tags" => double(field: "tags_ssim") }
    )
  end

  describe "link_to_search" do
    let(:view_context) { double(blacklight_config: blacklight_config, search_state: double(reset: double(add_facet_params: true)), search_action_path: "/exhibit/catalog") }
    let(:blacklight_config) do
      double(
        show_fields: {
          field: double(highlight: false, accessor: nil, default: nil, field: "field", text_area: false, helper_method: nil, link_to_search: "field", itemprop: nil, separator_options: nil, :separator_options= => nil)
        },
        view_config: double(title_field: "title", html_title_field: nil),
        facet_fields: { "exhibit_tags" => double(field: "tags_ssim") }
      )
    end

    before do
      allow(view_context).to receive(:link_to).with("بي", "/exhibit/catalog").and_return("<a link>بي</a link>".html_safe)
    end

    it "links each individual property" do
      field = presenter.field_config("field")
      expect(presenter.field_value(field)).to eq "<ul><li dir=\"rtl\"><a link>بي</a link></li></ul>"
    end
  end

  describe "#field_value" do
    context "when given a RTL string" do
      it "renders it as a RTL list item" do
        field = presenter.field_config("field")
        expect(presenter.field_value(field)).to eq "<ul><li dir=\"rtl\">بي</li></ul>"
      end
    end

    context "when given a string with special characters" do
      it "renders it without escaping them" do
        field = presenter.field_config("special")
        expect(presenter.field_value(field)).to eq "<ul><li dir=\"ltr\">Traité sur l'art de la charpente : théorique et pratique</li></ul>"
      end
    end

    context "when given a collection field" do
      it "renders links to each collection" do
        allow(view_context).to receive(:exhibit_path).with(exhibit).and_return("/#{exhibit.slug}")
        field = presenter.field_config("readonly_collections_ssim")
        expect(presenter.field_value(field)).to eq "<ul><li dir=\"ltr\"><a href=\"/#{exhibit.slug}\">#{exhibit.title}</a></li></ul>"
      end
    end
  end

  describe "#heading" do
    let(:blacklight_config) do
      double(
        show_fields: {
          field: double(highlight: false, accessor: nil, default: nil, field: "field", text_area: false, helper_method: nil, link_to_search: nil, itemprop: nil, separator_options: nil, :separator_options= => nil)
        },
        view_config: double(title_field: "title", html_title_field: nil),
        facet_fields: {}
      )
    end

    it "returns multiple titles appropriately" do
      expect(presenter.header).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">Traité sur l'art de la charpente : théorique et pratique</li></ul>"
    end
    context "when there's an override title" do
      let(:document) do
        SolrDocument.new(
          field: ["بي"],
          special: ["Traité sur l'art de la charpente : théorique et pratique"],
          title: ["بي", "Traité sur l'art de la charpente : théorique et pratique"],
          "override-title_ssim": ["Test"]
        )
      end

      it "uses it" do
        expect(presenter.header).to eq "<ul><li dir=\"ltr\">Test</li></ul>"
      end
    end

    context "when there's a blank override title" do
      let(:document) do
        SolrDocument.new(
          field: ["بي"],
          special: ["Traité sur l'art de la charpente : théorique et pratique"],
          title: ["بي", "Traité sur l'art de la charpente : théorique et pratique"],
          "override-title_ssim": [""]
        )
      end

      it "uses the default title" do
        expect(presenter.header).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">Traité sur l'art de la charpente : théorique et pratique</li></ul>"
      end
    end
  end

  describe "#html_title" do
    it "returns multiple titles appropriately" do
      expect(presenter.html_title).to eq "بي, Traité sur l'art de la charpente : théorique et pratique"
    end
    context "when there's an override title" do
      let(:document) do
        SolrDocument.new(
          field: ["بي"],
          special: ["Traité sur l'art de la charpente : théorique et pratique"],
          title: ["بي", "Traité sur l'art de la charpente : théorique et pratique"],
          "override-title_ssim": ["<i>Test</i>"]
        )
      end

      it "uses it" do
        expect(presenter.html_title).to eq "Test"
      end
    end

    context "when there's a blank override title" do
      let(:document) do
        SolrDocument.new(
          field: ["بي"],
          special: ["Traité sur l'art de la charpente : théorique et pratique"],
          title: ["بي", "Traité sur l'art de la charpente : théorique et pratique"],
          "override-title_ssim": [""]
        )
      end

      it "uses the default title" do
        expect(presenter.html_title).to eq "بي, Traité sur l'art de la charpente : théorique et pratique"
      end
    end

    context "when there's no override title" do
      let(:document) do
        SolrDocument.new(
          field: ["بي"],
          special: ["Traité sur l'art de la charpente : théorique et pratique"],
          title: ["بي", "Traité sur l'art de la charpente : théorique et pratique"]
        )
      end

      it "uses the default title" do
        expect(presenter.html_title).to eq "بي, Traité sur l'art de la charpente : théorique et pratique"
      end
    end
  end
end
