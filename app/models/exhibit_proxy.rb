class ExhibitProxy
  attr_reader :exhibit
  def initialize(exhibit)
    @exhibit = exhibit
  end

  def reindex
    IIIFIngestJob.perform_now members, exhibit
  end

  def collection_manifest
    CollectionManifest.find_by_slug(exhibit.slug)
  end

  def members
    collection_manifest.manifests.map { |x| x['@id'] }
  end

  def waiting!
  end
end
