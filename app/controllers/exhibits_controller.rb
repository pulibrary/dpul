class ExhibitsController < Spotlight::ExhibitsController
  prepend_before_action :find_exhibit
  after_action :ingest_members, only: :create

  def ingest_members
    return unless @exhibit.persisted?
    collection_manifest = CollectionManifest.find_by_slug(@exhibit.slug)
    members = collection_manifest.manifests.map { |x| x['@id'] }
    IIIFIngestJob.new.perform members, @exhibit
  end

  private

    def find_exhibit
      @exhibit ||=
        decorate(
          Spotlight::Exhibit.new
        )
    end

    def decorate(obj)
      AppliesTitleFromSlug.new(obj, params[:exhibit][:slug])
    end
end
