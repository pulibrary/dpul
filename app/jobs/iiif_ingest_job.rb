# frozen_string_literal: true

class IIIFIngestJob < ActiveJob::Base
  # Ingest one or more IIIF manfiest URLs.  Each manifest is ingested as its
  # own resource.
  def perform(urls, exhibit, log_entry = nil)
    Array.wrap(urls).each do |url|
      ingest url, exhibit
    end

    return unless log_entry

    # Lock the row to prevent multiple workers from overwriting each other's increments.
    # This worked, but it's reporting complete before the objects are reindexed.
    # app/models/spotlight/resource.rb:55 has a null reindexing_log_entry.
    log_entry.with_lock do
      previous = log_entry.items_reindexed_count || 0
      log_entry.update(items_reindexed_count: previous + Array.wrap(urls).size)
    end
  end

  # Ingest a single IIIF manifest URL as a resource.
  def ingest(url, exhibit)
    IIIFResource.find_or_initialize_by(url: url, exhibit_id: exhibit.id).save_and_index_now
  end
end
