class ExternalCollectionsQuery
  class << self
    def all
      new(remote_url).collection_manifests
    end

    private

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
