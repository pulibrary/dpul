class SearchBuilder
  class JoinChildrenQuery
    attr_reader :parent_query
    def initialize(parent_query)
      @parent_query = parent_query
    end

    def to_s
      queries.map do |query|
        "(#{dismax_join(send(query))})"
      end.join(" OR ")
    end

    private

      def queries
        [
          :main_query,
          :query_children
        ]
      end

      def dismax_join(query)
        "#{query}{!dismax}#{parent_query}"
      end

      def main_query
        ""
      end

      def query_children
        "{!join from=collection_id_ssim to=id}"
      end
  end
end
