# frozen_string_literal: true

class FiggyEventProcessor
  class Processor
    attr_reader :event
    def initialize(event)
      @event = event
    end

    private

      def exhibits
        Spotlight::Exhibit.where("slug IN (?)", collection_slugs)
      end

      def manifest_url
        event["manifest_url"]
      end

      def collection_slugs
        event["collection_slugs"]
      end

      def event_type
        event["event"]
      end

      def index
        Blacklight.default_index.connection
      end
  end
end
