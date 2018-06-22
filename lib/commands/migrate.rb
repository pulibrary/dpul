#!/usr/bin/env ruby

require "thor"

class Migrate < Thor
  desc "exhibit_thumbnails", "Migrate the IIIF Manifests to the latest IIIF image service points"
  def exhibit_thumbnails
    Spotlight::ExhibitThumbnail.all.each do |exhibit_thumbnail|
      Rails.logger.debug "Retrieving the Solr Document for #{exhibit_thumbnail}..."
      document = exhibit_thumbnail.document
      next unless document && document["readonly_references_ssim"] && !document["readonly_references_ssim"].empty?

      references_values = document["readonly_references_ssim"].first
      references = JSON.parse(references_values)

      next unless references["iiif_manifest_paths"]
      iiif_manifest_url = references["iiif_manifest_paths"].values.first

      Rails.logger.debug "Retrieving the IIIF Manifest for #{exhibit_thumbnail}..."
      begin
        response = Faraday.get(iiif_manifest_url)
        unless response.success?
          Rails.logger.warn("Failed to get #{iiif_manifest_url}")
          next
        end
      rescue Faraday::Error::ConnectionFailed, Faraday::TimeoutError => error
        Rails.logger.warn("Failed to get #{iiif_manifest_url}: #{error}")
        next
      end

      iiif_manifest_values = response.body
      iiif_manifest = JSON.parse(iiif_manifest_values)

      sequence = iiif_manifest["sequences"].first

      next if document["access_identifier_ssim"].blank?
      access_identifier = document["access_identifier_ssim"].first

      canvas = sequence["canvases"].find do |c|
        c["local_identifier"] == access_identifier
      end

      next unless canvas
      iiif_canvas_id = canvas["@id"]

      images = canvas["images"]
      image = images.first
      resource = image["resource"]
      service = resource["service"]

      iiif_tilesource = service["@id"]

      exhibit_thumbnail.iiif_manifest_url = iiif_manifest_url
      exhibit_thumbnail.iiif_canvas_id = iiif_canvas_id
      exhibit_thumbnail.iiif_tilesource = iiif_tilesource

      Rails.logger.debug "Updating #{exhibit_thumbnail}..."
      begin
        exhibit_thumbnail.save
      rescue StandardError => error
        Rails.logger.warn "Failed to update ExhibitThumbnail for #{exhibit_thumbnail.iiif_manifest_url}: #{error}"
        next
      end
    end
  end
end

Migrate.start(ARGV)
