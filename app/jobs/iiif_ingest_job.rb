class IIIFIngestJob < ActiveJob::Base
  # Ingest one or more IIIF manfiest URLs.  Each manifest is ingested as its
  # own resource.
  def perform(urls)
    Array.wrap(urls).each do |url|
      ingest url
    end
  end

  # Ingest a single IIIF manifest URL as a resource.
  def ingest(url)
    IIIFResource.new(manifest_url: url).save
  end
end
