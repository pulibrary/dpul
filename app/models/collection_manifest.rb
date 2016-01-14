class CollectionManifest < IIIF::Presentation::Collection
  def self.load(url)
    new(ExternalManifest.load(url).send(:data))
  end

  def self.find_by_slug(slug)
    ExternalCollectionsQuery.all.find do |manifest|
      manifest.slug == slug
    end
  end

  def slug
    metadata.find do |entry|
      entry["label"] == slug_key
    end["value"].first["@value"]
  end

  private

    def slug_key
      "Exhibit"
    end
end
