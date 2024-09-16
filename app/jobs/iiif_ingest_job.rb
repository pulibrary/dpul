# frozen_string_literal: true

class IiifIngestJob < ActiveJob::Base
  # Ingest one or more IIIF manfiest URLs.  Each manifest is ingested as its
  # own resource.
  def perform(urls, exhibit)
    Array.wrap(urls).each do |url|
      ingest url, exhibit
    end
  end

  # Ingest a single IIIF manifest URL as a resource.
  def ingest(url, exhibit)
    IiifResource.find_or_initialize_by(url:, exhibit_id: exhibit.id).save_and_index_now
  end
end
