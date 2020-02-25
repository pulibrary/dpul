# frozen_string_literal: true

FactoryBot.define do
  factory :iiif_resource, class: IIIFResource do
    transient do
      # Fixture to use for stubbing the manifest.
      manifest_fixture { nil }
      # Source metadata identifier to stub out
      source_metadata_identifier { nil }
      # Stubbed OCR content
      stubbed_ocr_content { nil }
      # Reference to the spec to enable the factory to stub out requests.
      spec { nil }
    end

    before(:create) do |resource, evaluator|
      if evaluator.spec.present?
        evaluator.spec.stub_manifest(url: resource.url, fixture: evaluator.manifest_fixture) if evaluator.manifest_fixture
        evaluator.spec.stub_metadata(id: evaluator.source_metadata_identifier) if evaluator.source_metadata_identifier
        evaluator.spec.stub_ocr_content(id: evaluator.source_metadata_identifier, text: evaluator.stubbed_ocr_content) if evaluator.source_metadata_identifier && evaluator.stubbed_ocr_content
      end
    end

    after(:create) do |resource, evaluator|
      resource.save_and_index
      Blacklight.default_index.connection.commit
    end
  end
end
