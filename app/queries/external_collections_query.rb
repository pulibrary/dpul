class ExternalCollectionsQuery
  class << self
    def all
      new(remote_url).collection_manifests
    end

    def uncreated
      exhibit_slugs = all_exhibit_slugs
      all.select do |manifest|
        !exhibit_slugs.include?(manifest.slug)
      end.sort_by(&:human_label)
    end

    private

      def all_exhibit_slugs
        Spotlight::Exhibit.pluck(:slug)
      end

      def remote_url
        Pomegranate.config["all_collection_manifest_url"]
      end
  end

  attr_reader :remote_url
  def initialize(remote_url)
    @remote_url = remote_url
  end

  def collection_manifests
    @collection_manifests ||= collections.map do |collection|
      CollectionManifest.new(collection.send(:data))
    end
  end

  private

    def all_manifest
      @all_manifest ||= ExternalManifest.load(remote_url)
    end

    def collections
      all_manifest.try(:collections) || []
    end
end
