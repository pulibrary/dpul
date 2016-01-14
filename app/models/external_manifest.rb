class ExternalManifest
  def self.load(external_uri)
    content = open(external_uri)
    IIIF::Service.parse(content.read)
  end
end
