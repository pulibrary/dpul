# frozen_string_literal: true

class ExternalManifest
  def self.load(external_uri)
    content = URI.open(external_uri, read_timeout: 3000)
    IIIF::Service.parse(content.read)
  end
end
