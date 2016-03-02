class CollectionManifest < IIIF::Presentation::Collection
  def self.find_by_slug(slug)
    ExternalCollectionsQuery.all.find do |manifest|
      manifest.slug == slug
    end
  end

  def slug
    metadata.find do |entry|
      entry["label"] == slug_key
    end["value"].first
  end

  private

    def slug_key
      "Exhibit"
    end
end
