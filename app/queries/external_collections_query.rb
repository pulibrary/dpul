class ExternalCollectionsQuery
  class << self
    def all
      new(remote_url).collection_manifests
    end

    private

      def remote_url
        "https://hydra-dev.princeton.edu/collections/manifest"
      end
  end

  attr_reader :remote_url
  def initialize(remote_url)
    @remote_url = remote_url
  end

  def collection_manifests
    @collection_manifests ||= manifest_urls.map do |url|
      CollectionManifest.load(url)
    end
  end

  private

    def all_manifest
      @all_manifest ||= ExternalManifest.load(remote_url)
    end

    def manifest_urls
      all_manifest.manifests.map do |manifest|
        manifest['@id']
      end
    end
end
