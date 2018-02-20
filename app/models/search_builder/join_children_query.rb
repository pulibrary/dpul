class SearchBuilder
  # Models Solr join queries for retrieving Documents modeling children of collections
  class JoinChildrenQuery
    attr_reader :parent_query
    # Constructor
    # @param parent_query [String] the query string from the client
    def initialize(parent_query)
      @parent_query = parent_query
    end

    # Generates the query string
    # @return [String]
    def to_s
      return parent_query if parent_query.to_s.start_with?("{!lucene}")
      q = queries.map do |query|
        "_query_: \"#{dismax_join(send(query))}\""
      end.join(" OR ")
      "{!lucene}#{q}"
    end

    private

      # Method names used to generate the query string
      # @return [Array<Symbol>] method names
      def queries
        [
          :main_query,
          :query_children
        ]
      end

      # Generates a disjunction max (dismax) join query string on the IDs of Documents modeling child resources of collections
      # @param query [String] dismax query used for the join
      # @return [String] the query string
      def dismax_join(query)
        cleaned_parent_query = parent_query.nil? ? "" : parent_query.gsub(/"/, '\"')
        "#{query}{!dismax}#{cleaned_parent_query}"
      end

      # Primary dismax query string
      # (This is meant to be overridden)
      # @return [String]
      def main_query
        ""
      end

      # Dismax query string joining collection_id_ssim on IDs for Solr Documents
      # @return [String]
      def query_children
        "{!join from=collection_id_ssim to=id}"
      end
  end
end
