# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RTLShowPresenter do
  subject(:presenter) { described_class.new(document, view_context) }

  let(:document) do
    SolrDocument.new(
      field: ["بي"],
      special: ["Traité sur l'art de la charpente : théorique et pratique"],
      title: ["بي", "Traité sur l'art de la charpente : théorique et pratique"]
    )
  end
  let(:view_context) { double(blacklight_config: blacklight_config, action_name: "show", controller_name: "catalog") }
  let(:blacklight_config) do
    double(
      show_fields: {
        field: double(highlight: false, accessor: nil, default: nil, field: "field", text_area: false, helper_method: nil, link_to_facet: nil, itemprop: nil, separator_options: nil, :separator_options= => nil)
      },
      view_config: double(title_field: "title", html_title_field: nil),
      facet_fields: { "exhibit_tags" => double(field: "tags_ssim") }
    )
  end

  describe "link_to_facet" do
    let(:view_context) { double(blacklight_config: blacklight_config, action_name: "show", controller_name: "catalog", search_state: double(reset: double(add_facet_params: true)), search_action_path: "/exhibit/catalog") }

    before do
      allow(view_context).to receive(:link_to).with("بي", "/exhibit/catalog").and_return("<a link>بي</a link>".html_safe)
    end

    it "links each individual property" do
      field = Blacklight::Configuration::Field.new(field: "field", link_to_facet: "field")
      expect(presenter.field_value(field)).to eq "<ul><li dir=\"rtl\"><a link>بي</a link></li></ul>"
    end
  end

  describe "#field_value" do
    context "when given a RTL string" do
      it "renders it as a RTL list item" do
        field = Blacklight::Configuration::Field.new(field: "field")
        expect(presenter.field_value(field)).to eq "<ul><li dir=\"rtl\">بي</li></ul>"
      end
    end

    context "when given a string with special characters" do
      it "renders it without escaping them" do
        field = Blacklight::Configuration::Field.new(field: "special")
        expect(presenter.field_value(field)).to eq "<ul><li dir=\"ltr\">Traité sur l'art de la charpente : théorique et pratique</li></ul>"
      end
    end
  end

  describe "#field_presenters" do
    it "returns presenters that render values as a list" do
      exhibit = FactoryBot.create(:exhibit)
      exhibit.blacklight_config.add_index_field "readonly_bla_ssim"
      presenter = described_class.new(
        SolrDocument.new("readonly_bla_ssim" => ["1", "2"]),
        double(should_render_field?: true, action_name: "show", controller_name: "catalog"),
        exhibit.blacklight_config
      )
      field_presenters = presenter.field_presenters.to_a
      expect(field_presenters[0].render).to eq '<ul><li dir="ltr">1</li><li dir="ltr">2</li></ul>'
    end
    it "returns presenters that render values as a sentence for search results" do
      exhibit = FactoryBot.create(:exhibit)
      exhibit.blacklight_config.add_index_field "readonly_bla_ssim"
      presenter = described_class.new(
        SolrDocument.new("readonly_bla_ssim" => ["1", "2"]),
        double(should_render_field?: true, action_name: "index", controller_name: "catalog"),
        exhibit.blacklight_config
      )
      field_presenters = presenter.field_presenters.to_a
      expect(field_presenters[0].render).to eq '1 and 2'
    end
    it "returns presenters that can handle text areas" do
      exhibit = FactoryBot.create(:exhibit)
      exhibit.blacklight_config.add_index_field "readonly_bla_ssim", text_area: "1"
      presenter = described_class.new(
        SolrDocument.new("readonly_bla_ssim" => ["{\"data\":[{\"type\":\"text\",\"data\":{\"text\":\"testing note\",\"format\":\"html\"}}]}"]),
        double(should_render_field?: true, action_name: "index", controller_name: "catalog"),
        exhibit.blacklight_config
      )
      field_presenters = presenter.field_presenters.to_a
      expect(field_presenters[0].render).to eq 'testing note'
    end
  end

  describe "#heading" do
    let(:presenter) do
      described_class.new(
        document,
        double(should_render_field?: true, action_name: "show", controller_name: "catalog"),
        CatalogController.blacklight_config
      )
    end

    let(:document) do
      SolrDocument.new(
        field: ["بي"],
        special: ["Traité sur l'art de la charpente : théorique et pratique"],
        full_title_tesim: ["بي", "Traité sur l'art de la charpente : théorique et pratique"]
      )
    end

    it "returns multiple titles appropriately" do
      expect(presenter.heading).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">Traité sur l'art de la charpente : théorique et pratique</li></ul>"
    end
    context "when there's an override title" do
      let(:document) do
        SolrDocument.new(
          field: ["بي"],
          special: ["Traité sur l'art de la charpente : théorique et pratique"],
          full_title_tesim: ["بي", "Traité sur l'art de la charpente : théorique et pratique"],
          "override-title_ssim": ["Test"]
        )
      end

      it "uses it" do
        expect(presenter.heading).to eq "<ul><li dir=\"ltr\">Test</li></ul>"
      end
    end

    context "when there's a blank override title" do
      let(:document) do
        SolrDocument.new(
          field: ["بي"],
          special: ["Traité sur l'art de la charpente : théorique et pratique"],
          full_title_tesim: ["بي", "Traité sur l'art de la charpente : théorique et pratique"],
          "override-title_ssim": [""]
        )
      end

      it "uses the default title" do
        expect(presenter.heading).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">Traité sur l'art de la charpente : théorique et pratique</li></ul>"
      end
    end
  end

  describe "#html_title" do
    let(:presenter) do
      described_class.new(
        document,
        double(should_render_field?: true, action_name: "show", controller_name: "catalog"),
        CatalogController.blacklight_config
      )
    end

    let(:document) do
      SolrDocument.new(
        field: ["بي"],
        special: ["Traité sur l'art de la charpente : théorique et pratique"],
        full_title_tesim: ["بي", "Traité sur l'art de la charpente : théorique et pratique"]
      )
    end

    it "returns multiple titles appropriately" do
      expect(presenter.html_title).to eq "بي, Traité sur l'art de la charpente : théorique et pratique"
    end
    context "when there's an override title" do
      let(:document) do
        SolrDocument.new(
          field: ["بي"],
          special: ["Traité sur l'art de la charpente : théorique et pratique"],
          full_title_tesim: ["بي", "Traité sur l'art de la charpente : théorique et pratique"],
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
          full_title_tesim: ["بي", "Traité sur l'art de la charpente : théorique et pratique"],
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
          full_title_tesim: ["بي", "Traité sur l'art de la charpente : théorique et pratique"]
        )
      end

      it "uses the default title" do
        expect(presenter.html_title).to eq "بي, Traité sur l'art de la charpente : théorique et pratique"
      end
    end
  end
end
