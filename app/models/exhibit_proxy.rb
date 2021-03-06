# frozen_string_literal: true

class ExhibitProxy
  attr_reader :exhibit
  def initialize(exhibit)
    @exhibit = exhibit
  end

  def reindex(log_entry = nil)
    members_to_remove_from_index.each(&:remove_from_solr)
    members.each do |member|
      IIIFIngestJob.perform_later member, exhibit, log_entry
    end
  end

  def collection_manifest
    CollectionManifest.find_by_slug(exhibit.slug)
  end

  def document_builder
    DummyDocumentBuilder.new(members)
  end

  # resource urls pulled from the manifest
  def members
    collection_manifest.manifests.map { |x| x['@id'] }
  end

  # resources pulled from the database
  def persisted_members
    IIIFResource.where(exhibit_id: exhibit.id)
  end

  # resources that are in the database but not in the manfiest
  def members_to_remove_from_index
    persisted_members.reject { |m| members.include?(m.url) }
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
