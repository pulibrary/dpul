# frozen_string_literal: true

FactoryBot.define do
  factory :iiif_resource, class: IiifResource do
    transient do
      # Fixture to use for stubbing the manifest.
      manifest_fixture { nil }
      # figgy id to stub out
      figgy_uuid { nil }
      # Stubbed OCR content
      stubbed_ocr_content { nil }
      # Reference to the spec to enable the factory to stub out requests.
      spec { nil }
    end

    before(:create) do |resource, evaluator|
      if evaluator.spec.present?
        evaluator.spec.stub_manifest(url: resource.url, fixture: evaluator.manifest_fixture) if evaluator.manifest_fixture
        evaluator.spec.stub_metadata(id: evaluator.figgy_uuid) if evaluator.figgy_uuid
        evaluator.spec.stub_ocr_content(id: evaluator.figgy_uuid, text: evaluator.stubbed_ocr_content) if evaluator.figgy_uuid && evaluator.stubbed_ocr_content
      end
    end

    after(:create) do |resource, evaluator|
      resource.save_and_index
      Blacklight.default_index.connection.commit
    end
  end
end
