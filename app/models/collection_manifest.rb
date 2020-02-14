# frozen_string_literal: true

class CollectionManifest < IIIF::Presentation::Collection
  def self.find_by_slug(slug)
    result = ExternalCollectionsQuery.all.find do |manifest|
      manifest.slug == slug
    end
    return nil if result.nil?
    CollectionManifest.new(ExternalManifest.load(result.id).send(:data))
  end

  def id
    id = self['@id']
    return id if Pomegranate.config["manifest_authorization_token"].blank?
    "#{id}?auth_token=#{Pomegranate.config['manifest_authorization_token']}"
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
