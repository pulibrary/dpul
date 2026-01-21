# frozen_string_literal: true

require "rails_helper"

describe CustomFieldRendering do
  subject(:rendered) { custom_field_rendering.render }

  let(:document) { instance_double(SolrDocument) }
  let(:context) { double }
  let(:options) { double }
  let(:stack) { [Blacklight::Rendering::Terminator] }
  let(:custom_field_rendering) do
    described_class.new(values, field_config, document, context, options, stack)
  end

  describe "#render" do
    let(:values) do
      '{"data":[{"type":"text","data":{"text":"testing note","format":"html"}}]}'
    end
    let(:field_config) { Blacklight::Configuration::NullField.new(text_area: "1", separator_options: nil) }

    it "parses the JSON and extracts the text" do
      expect(rendered).to eq "testing note"
    end

    context "when the JSON is invalid" do
      let(:values) do
        "@#123"
      end

      it "renders the original string" do
        expect(rendered).to eq values
      end
    end
  end
end
