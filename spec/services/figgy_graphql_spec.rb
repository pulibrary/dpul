require 'rails_helper'

RSpec.describe FiggyGraphql do
  let(:schema) { instance_double(GraphQL::Schema) }
  let(:client) { instance_double(GraphQL::Client) }
  let(:query) { instance_double(GraphQL::Client::OperationDefinition) }
  let(:data) do
    instance_double(GraphQL::Client::Response,
                    data: OpenStruct.new(
                      resource: OpenStruct.new(
                        ocr_content: ocr_content
                      )
                    ))
  end
  let(:ocr_content) { ["Content".freeze] }

  before do
    allow(GraphQL::Client).to receive(:load_schema).and_return(schema)
    allow(GraphQL::Client).to receive(:new).and_return(client)
    allow(client).to receive(:parse).and_return(query)
    allow(client).to receive(:query).with(
      query,
      variables: {
        id: anything
      }
    ).and_return(
      data
    )
  end
  after do
    described_class.instance_variable_set(:@schema, nil)
    described_class.instance_variable_set(:@client, nil)
    described_class.instance_variable_set(:@ocr_content_query, nil)
    described_class.send(:remove_const, :OCRQuery) if defined?(FiggyGraphql::OCRQuery)
  end

  describe ".schema" do
    it "returns a schema" do
      expect(described_class.schema).to eq schema
    end
  end

  describe ".client" do
    it "returns a GraphQL client" do
      expect(described_class.client).to eq client
    end
  end

  describe ".ocr_content_query" do
    it "sets a constant to a query" do
      expect(defined?(FiggyGraphql::OCRQuery)).to eq nil

      described_class.ocr_content_query

      expect(defined?(FiggyGraphql::OCRQuery)).to eq "constant"
    end
  end

  describe ".get_ocr_content_for_id" do
    it "runs the query with the given ID and returns ocr content" do
      expect(described_class.get_ocr_content_for_id(id: "test")).to eq ["Content"]
    end
  end
end
