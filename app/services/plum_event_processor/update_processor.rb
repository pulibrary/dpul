class PlumEventProcessor
  class UpdateProcessor < Processor
    def process
      delete_old_resources
      update_existing_resources
      create_new_resources
      true
    end

    def delete_old_resources
      delete_resources.each do |resource|
        resource.to_solr.map { |x| x[:id] }.each do |id|
          index.delete_by_id id.to_s
          index.commit
        end
        resource.destroy
      end
    end

    def update_existing_resources
      IIIFResource.where(url: manifest_url).each do |resource|
        next if resource.save_and_index
        # Make solr document private if it's no longer valid.
        manifest = Spotlight::Resources::IiifManifest.new(url: resource.url)
        manifest.with_exhibit(resource.exhibit)
        document = SolrDocument.find(manifest.compound_id)
        if document
          document.make_private!(resource.exhibit)
          document.save
        end
      end
    end

    def create_new_resources
      new_exhibits.each do |exhibit|
        IIIFResource.new(manifest_url: manifest_url, exhibit: exhibit).save_and_index
      end
    end

    private

      def new_exhibits
        Spotlight::Exhibit.where("slug IN (?)", new_exhibit_slugs)
      end

      def new_exhibit_slugs
        collection_slugs - existing_slugs
      end

      def delete_resources
        IIIFResource.where(url: manifest_url).joins(:exhibit).where('spotlight_exhibits.slug IN (?)', delete_slugs)
      end

      def delete_slugs
        existing_slugs - collection_slugs
      end

      def existing_slugs
        existing_resources.map(&:exhibit).map(&:slug)
      end

      def existing_resources
        IIIFResource.where(url: manifest_url)
      end
  end
end
