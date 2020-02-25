# frozen_string_literal: true

class CollectionManifest < IIIF::Presentation::Collection
  def self.find_by_slug(slug)
    result = ExternalCollectionsQuery.all.find do |manifest|
      manifest.slug == slug
    end
    return nil if result.nil?

    CollectionManifest.new(ExternalManifest.load(result.id).send(:data))
  end

  # Overwriting this method isn't the best, as it's not an accurate
  # representation of what comes through, but Spotlight's indexer calls #id in
  # multiple places to ask for the manifest, and we need to make sure the auth
  # token is included.
  def id
    AuthorizedUrl.new(url: self['@id']).to_s
  end

  def slug
    metadata.find do |entry|
      entry["label"] == slug_key
    end["value"].first
  end

  def human_label
    Array.wrap(label).first
  end

  private

    def slug_key
      "Exhibit"
    end
end
