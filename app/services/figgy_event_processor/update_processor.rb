# frozen_string_literal: true

class FiggyEventProcessor
  class UpdateProcessor < Processor
    def process
      delete_old_resources
      update_existing_resources
      create_new_resources
      true
    end

    def delete_old_resources
      delete_resources.each(&:destroy)
    end

    def update_existing_resources
      IIIFResource.where(url: manifest_url).each(&:save_and_index)
    end

    def create_new_resources
      new_exhibits.each do |exhibit|
        IIIFResource.new(url: manifest_url, exhibit: exhibit).save_and_index
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
        existing_resources.map(&:exhibit).select(&:present?).map(&:slug)
      end

      def existing_resources
        IIIFResource.where(url: manifest_url)
      end
  end
end
