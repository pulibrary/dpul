require 'rails_helper'

describe ApplicationHelper, type: :helper do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:field) { instance_double(Spotlight::CustomField) }
  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    blacklight_config.index_fields['foo_tesim'] = OpenStruct.new('text_area' => "1")
    allow(field).to receive(:field).and_return("foo_tesim")
    allow(exhibit).to receive_messages(blacklight_config: blacklight_config)
  end
  describe '#text_area?' do
    let(:output) { helper.text_area?(field, exhibit) }

    it "determines whether or not a field should be rendered as a text_area" do
      expect(output).to be true
    end
  end

  describe '#text_area_value' do
    let(:sidecar) { instance_double(Spotlight::SolrDocumentSidecar) }
    let(:output) { helper.text_area_value(field, sidecar) }
    let(:data) do
      [{ type: "text", data: { text: "testing note", format: "html" } }]
    end

    before do
      allow(sidecar).to receive(:data).and_return('foo_tesim' => { data: data })
    end
    it "normalizes the text area value" do
      expect(output).to eq(data: data)
    end
  end
end
