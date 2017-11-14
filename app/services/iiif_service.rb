class IiifService < Spotlight::Resources::IiifService
  def self.iiif_response(url)
    resp = Faraday.get(url)
    if resp.success?
      resp.body
    else
      Rails.logger.info("Failed to get #{url}")
      {}.to_json
    end
  rescue Faraday::Error::ConnectionFailed, Faraday::TimeoutError => e
    Rails.logger.warn("HTTP GET for #{url} failed with #{e}")
    {}.to_json
  end

  def create_iiif_manifest(manifest, collection = nil)
    IiifManifest.new(url: manifest['@id'], manifest: manifest, collection: collection)
  end
end
