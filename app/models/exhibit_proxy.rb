# frozen_string_literal: true

# Used for reindexing an exhibit. This object caches a members list
# so should always be re-instantiated before use.
class ExhibitProxy
  attr_reader :exhibit
  def initialize(exhibit)
    @exhibit = exhibit
  end

  def reindex(*_args)
    members_to_remove_from_index.each(&:remove_from_solr)
    members.each do |member|
      IIIFIngestJob.perform_later member, exhibit
    end
  end

  # Map all of the members to IIIFResource objects
  def resources
    @resources ||= members.map { |url| IIIFResource.find_or_initialize_by(url: url, exhibit_id: exhibit.id) }
  end

  def collection_manifest
    CollectionManifest.find_by_slug(exhibit.slug)
  end

  def document_builder
    DummyDocumentBuilder.new(members)
  end

  # resource urls pulled from the manifest
  def members
    @members ||= collection_manifest.manifests.map { |x| x['@id'] }
  end

  # resources pulled from the database
  def persisted_members
    IIIFResource.where(exhibit_id: exhibit.id)
  end

  # resources that are in the database but not in the manfiest
  def members_to_remove_from_index
    persisted_members.reject { |m| members.include?(m.bare_url) }
  end

  def waiting!; end

  class DummyDocumentBuilder
    attr_reader :members
    def initialize(members)
      @members = members
    end

    def documents_to_index
      members
    end
  end
end
