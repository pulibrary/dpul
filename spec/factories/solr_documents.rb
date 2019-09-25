# SolrDoc is a pretty weird sort of object; you can set values in a hash passed
# to new but you can't set them later. Advise to use SolrDocument.new directly
# when you need anything more than id.
FactoryBot.define do
  factory :solr_document, class: SolrDocument, aliases: [:document] do
    sequence(:id) { |n| n.to_s }
    initialize_with { new(id: id) }
  end
end
