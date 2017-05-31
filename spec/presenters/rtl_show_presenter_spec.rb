require 'rails_helper'

RSpec.describe RTLShowPresenter do
  subject(:presenter) { described_class.new(document, double(blacklight_config: blacklight_config)) }

  let(:document) do
    SolrDocument.new(
      field: ["بي"],
      special: ["Traité sur l'art de la charpente : théorique et pratique"],
      title: ["بي", "Traité sur l'art de la charpente : théorique et pratique"]
    )
  end
  let(:cc_config) { CatalogController.new.blacklight_config }
  let(:blacklight_config) do
    double(
      show_fields: { field:
                    double(highlight: false, accessor: nil, default: nil, field: :field, helper_method: nil, link_to_search: nil, itemprop: nil, separator_options: nil, :separator_options= => nil) },
      view_config: double(title_field: :title)
    )
  end

  describe "#field_value" do
    context "when given a RTL string" do
      it "renders it as a RTL list item" do
        expect(presenter.field_value(:field)).to eq "<ul><li dir=\"rtl\">بي</li></ul>"
      end
    end
    context "when given a string with special characters" do
      it "renders it without escaping them" do
        expect(presenter.field_value(:special)).to eq "<ul><li dir=\"ltr\">Traité sur l'art de la charpente : théorique et pratique</li></ul>"
      end
    end
  end

  describe "#heading" do
    it "returns multiple titles appropriately" do
      expect(presenter.header).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">Traité sur l'art de la charpente : théorique et pratique</li></ul>"
    end
  end
end
