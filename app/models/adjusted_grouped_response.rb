# frozen_string_literal: true

class AdjustedGroupedResponse < Blacklight::Solr::Response
  def initialize(*args)
    data = FacetCount.new(args.first)
    data.adjust! if data.field && data.num_found
    super
  end

  class FacetCount
    attr_reader :data
    def initialize(data)
      @data = data
    end

    def field
      return nil unless data.try(:[], "facet_counts").try(:[], "facet_fields")

      data["facet_counts"]["facet_fields"][identifying_facet]
    end

    def num_found
      Hash[field.each_slice(2).to_a]["iiif_resources"]
    end

    def adjust!
      data["response"]["numFound"] = num_found
      data["facet_counts"]["facet_fields"].delete(identifying_facet)
    end

    private

      def identifying_facet
        "spotlight_resource_type_ssim"
      end
  end
end
