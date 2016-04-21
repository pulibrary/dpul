require 'rails_helper'

RSpec.describe RTLPresenter do
  let(:document) do
    {
      field: ["بي"]
    }
  end
  let(:blacklight_config) do
    double(
      show_fields: { field:
                    double(highlight: false, accessor: nil, default: nil, field: :field, helper_method: nil, link_to_search: nil, itemprop: nil, separator: nil)
    })
  end
  subject { described_class.new(document, double(blacklight_config: blacklight_config)) }
  describe "#render_document_show_field_value" do
    context "when given a RTL string" do
      it "renders it as a RTL list item" do
        expect(subject.render_document_show_field_value(:field)).to eq "<ul><li dir=\"rtl\">بي</li></ul>"
      end
    end
  end
end
