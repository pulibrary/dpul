FactoryBot.define do
  factory :solr_document, class: SolrDocument, aliases: [:document] do
    sequence(:id) { |n| n.to_s }
    initialize_with { new(id: id) }
  end
end
