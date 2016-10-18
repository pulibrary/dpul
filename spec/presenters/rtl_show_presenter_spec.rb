require 'rails_helper'

RSpec.describe RTLShowPresenter do
  subject(:presenter) { described_class.new(document, double(blacklight_config: blacklight_config)) }

  let(:document) do
    {
      field: ["بي"]
    }
  end
  let(:blacklight_config) do
    double(
      show_fields: { field:
                    double(highlight: false, accessor: nil, default: nil, field: :field, helper_method: nil, link_to_search: nil, itemprop: nil, separator_options: nil) }
    )
  end

  describe "#field_value" do
    context "when given a RTL string" do
      it "renders it as a RTL list item" do
        expect(presenter.field_value(:field)).to eq "<ul><li dir=\"rtl\">بي</li></ul>"
      end
    end
  end
end