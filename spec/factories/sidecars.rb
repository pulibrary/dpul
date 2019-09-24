FactoryBot.define do
  factory :sidecar, class: Spotlight::SolrDocumentSidecar do
    association :document, factory: :solr_document, strategy: :build
    association :exhibit
    data {}

    transient do
      manifest_url { "http://example.com/manifest" }
      access_id { nil }
      custom_fields { {} }
      with_indexed_document { false }
    end

    after(:create) do |sidecar, evaluator|
      sidecar.data["content_metadata_iiif_manifest_field_ssi"] = evaluator.manifest_url if evaluator.manifest_url
      sidecar.data["access_identifier_ssim"] = [evaluator.access_id] if evaluator.access_id
      evaluator.custom_fields.each do |k, v|
        sidecar.data["exhibit_#{sidecar.exhibit.slug}_#{k}_tesim"] = [v]
      end
      if evaluator.with_indexed_document
        sidecar.document.make_public! sidecar.exhibit
        sidecar.document.reindex
      end
    end
  end
end
