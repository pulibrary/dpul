class IiifService < Spotlight::Resources::IiifService
  def create_iiif_manifest(manifest, collection = nil)
    IiifManifest.new(url: manifest['@id'], manifest: manifest, collection: collection)
  end
end
