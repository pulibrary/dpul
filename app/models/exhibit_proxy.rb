# frozen_string_literal: true

class ExhibitProxy
  attr_reader :exhibit
  def initialize(exhibit)
    @exhibit = exhibit
  end

  def reindex(log_entry = nil)
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

  class DummyDocumentBuilder
    attr_reader :members
    def initialize(members)
      @members = members
    end

    def documents_to_index
      members
    end
  end

  def members
    collection_manifest.manifests.map { |x| x['@id'] }
  end

  def waiting!
  end
end
