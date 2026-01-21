# frozen_string_literal: true

class IiifService < ::Spotlight::Resources::IiifService
  def self.iiif_response(url)
    authorized_url = AuthorizedUrl.new(url:).to_s
    resp = Spotlight::Resources::IiifService.http_client.get(authorized_url)
    if resp.success?
      resp.body
    else
      Rails.logger.info("Failed to get #{url}")
      {}.to_json
    end
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
    Rails.logger.warn("HTTP GET for #{url} failed with #{e}")
    {}.to_json
  end

  def create_iiif_manifest(manifest, collection = nil)
    IiifManifest.new(url: manifest["@id"] || manifest["id"], manifest:, collection:)
  end

  def object
    @object ||= ManifestParser.parse(JSON.parse(response))
  end

  def manifest?
    object.is_a?(IIIF::Presentation::Manifest) || object.is_a?(ManifestParser::IIIF3Manifest)
  end

  class ManifestParser
    def self.parse(json)
      return IIIF::Service.parse(json.to_json) unless json["@context"]&.include?("http://iiif.io/api/presentation/3/context.json")

      IIIF3Manifest.new(json)
    end

    # IIIF::Presentation doesn't support IIIF 3. Fortunately we don't use much
    # of it, so a simple wrapper with a label for a manifest gets us there.
    class IIIF3Manifest < SimpleDelegator
      def label
        __getobj__["label"].flat_map { |_k, v| v }
      end
    end
  end
end
