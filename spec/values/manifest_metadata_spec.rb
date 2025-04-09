# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManifestMetadata do
  subject(:metadata) { described_class.new("http://example.com/1234") }

  let(:plain_value) { { "Title" => ["Plain"] } }
  let(:at_value) { { "Title" => { "@value" => "Value Text" } } }
  let(:pref_value) { { "Title" => { "pref_label" => "Pref Label Text" } } }
  let(:lang_code) { { "Language" => "en" } }
  let(:member) { { "Memberof" => { "title" => "Member Title" } } }
  let(:id_value) { { "Title" => { "@id" => "1234" } } }
  let("rights") { { "Edm rights" => "Rights Text" } }
  let(:date_range_value) do
    { "date_range" => [
      {
        "@type" => "edm:TimeSpan", # ????
        "begin" => ["1992"],
        "end" => ["1993"],
        "skos:prefLabel" => "approximately 1992-1993",
        "crm:P79_beginning_is_qualified_by" => "approximate",
        "crm:P80_end_is_qualified_by" => "approximate"
      }
    ] }
  end
  let(:keywords_value) do
    {
      "keywords" => [
        "Christianity",
        "people's movement",
        "liberation theology"
      ]
    }
  end

  describe "#process_values" do
    it "doesn't modify a plain value" do
      expect(metadata.process_values(plain_value)).to eq("Title" => ["Plain"])
    end
    it "uses @value if present" do
      expect(metadata.process_values(at_value)).to eq("Title" => ["Value Text"])
    end
    it "uses pref_label if present" do
      expect(metadata.process_values(pref_value)).to eq("Title" => ["Pref Label Text"])
    end
    it "uses skos:prefLabel if present" do
      expect(metadata.process_values(date_range_value)).to eq("date_range" => ["approximately 1992-1993"])
    end
    it "looks up language code labels" do
      expect(metadata.process_values(lang_code)).to eq("Language" => ["English"])
    end
    it "uses member titles" do
      expect(metadata.process_values(member)).to eq("Collections" => ["Member Title"])
    end
    it "calls edm-rights rights" do
      expect(metadata.process_values(rights)).to eq("Rights" => ["Rights Text"])
    end
    it "uses @id as a last resort" do
      expect(metadata.process_values(id_value)).to eq("Title" => ["1234"])
    end
    it "downcases keywords for consistent storage" do
      expect(metadata.process_values(keywords_value)).to eq("keywords" => ["christianity", "people's movement", "liberation theology"])
    end
  end
end
