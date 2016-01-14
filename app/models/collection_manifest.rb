class CollectionManifest < IIIF::Presentation::Collection
  def self.load(url)
    new(ExternalManifest.load(url).send(:data))
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
