# frozen_string_literal: true

# Patches send_one to only send two arguments to Etl::Executor#on_error
# TODO: Remove when fixed upstream. See
#   https://github.com/projectblacklight/spotlight/issues/2778
module SolrLoaderPatch
  def send_one(document, pipeline)
    blacklight_solr.update params: { commitWithin: 500 },
                           data: [document].to_json,
                           headers: { 'Content-Type' => 'application/json' }
  rescue StandardError => e
    pipeline&.on_error(e, document.to_json)
  end
end

Spotlight::Etl::SolrLoader.prepend(SolrLoaderPatch)
