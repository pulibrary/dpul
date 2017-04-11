class ExhibitProxy
  attr_reader :exhibit
  def initialize(exhibit)
    @exhibit = exhibit
  end

  def reindex(*_args)
    members.each_slice(50) do |slice|
      IIIFIngestJob.perform_later slice, exhibit
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
