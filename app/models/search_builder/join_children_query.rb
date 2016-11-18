class SearchBuilder
  class JoinChildrenQuery
    attr_reader :parent_query
    def initialize(parent_query)
      @parent_query = parent_query
    end

    def to_s
      return parent_query if parent_query.to_s.start_with?("{!lucene}")
      q = queries.map do |query|
        "_query_: \"#{dismax_join(send(query))}\""
      end.join(" OR ")
      "{!lucene}#{q}"
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
