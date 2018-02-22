# pulled and pared down from spotlight
# https://github.com/projectblacklight/spotlight/blob/b4608610ed0405f1d8ed4d6c9c17a02b06b9bcf6/spec/fixtures/iiif_responses.rb
module IiifResponses
  def test_manifest1
    {
      "@id": 'uri://for-manifest1/manifest',
      "@type": 'sc:Manifest',
      "label": 'Test Manifest 1',
      "attribution": 'Attribution Data',
      "description": 'A test IIIF manifest',
      "license": 'http://www.example.org/license.html',
      "metadata": [
        {
          "label": 'Author',
          "value": 'John Doe'
        },
        {
          "label": 'Author',
          "value": 'Jane Doe'
        },
        {
          "label": 'Another Field',
          "value": 'Some data'
        },
        {
          "label": 'Date',
          "value": '1929'
        }
      ],
      "thumbnail": {
        "@id": 'uri://to-thumbnail'
      },
      "sequences": [
        {
          "@type": 'sc:Sequence',
          "canvases": [
            {
              "@type": 'sc:Canvas',
              "images": [
                {
                  "@type": 'oa:Annotation',
                  "resource": {
                    "@type": 'dcterms:Image',
                    "@id": 'uri://full-image',
                    "service": {
                      "@id": 'uri://to-image-service'
                    }
                  }
                }
              ]
            }
          ]
        }
      ]
    }.to_json
  end
end
