# frozen_string_literal: true

# A secret token used to encrypt user_id's in the Bookmarks#export callback URL
# functionality, for example in Refworks export of Bookmarks. In Rails 4, Blacklight
# will use the application's secret key base instead.
#

# Blacklight.secret_key = '99d542f85bffaadb98670ae96ff5f860c910ede7fb262d48c345ff9d06d7d21ff5533bb8a26934f7067a24b2510f590d25bc6765c9cb02d56ec1e2c83dc78168'

Blacklight::Rendering::Pipeline.operations = [Blacklight::Rendering::HelperMethod,
                                              Blacklight::Rendering::LinkToFacet,
                                              Blacklight::Rendering::Microdata,
                                              Blacklight::Rendering::Join,
                                              CustomFieldRendering]
