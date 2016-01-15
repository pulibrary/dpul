class IIIFIngestJob < ActiveJob::Base
  # Ingest one or more IIIF manfiest URLs.  Each manifest is ingested as its
  # own resource.
  def perform(urls, exhibit)
    Array.wrap(urls).each do |url|
      ingest url, exhibit
    end
  end

  # Ingest a single IIIF manifest URL as a resource.
  def ingest(url, exhibit)
    IIIFResource.new(manifest_url: url, exhibit: exhibit).save_and_index
  end
end
