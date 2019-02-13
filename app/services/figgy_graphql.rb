module FiggyGraphql
  require "graphql/client"
  require "graphql/client/http"
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP = GraphQL::Client::HTTP.new("https://figgy.princeton.edu/graphql")

  # Fetch latest schema on init, this will make a network request
  def self.schema
    @schema ||= GraphQL::Client.load_schema(HTTP)
  end

  def self.client
    @client ||= GraphQL::Client.new(schema: schema, execute: HTTP)
  end

  def self.ocr_content_query
    @ocr_content_query ||=
      begin
        query =
          <<-'GRAPHQL'
              query($id: ID!) {
                resource(id: $id) {
                  ocrContent
                }
              }
        GRAPHQL
        FiggyGraphql.const_set(:OCRQuery, client.parse(query))
      end
  end

  def self.get_ocr_content_for_id(id:)
    ocr_content_query
    client.query(
      FiggyGraphql::OCRQuery,
      variables: { id: id }
    ).data.try(:resource).try(:ocr_content)
  end
end
