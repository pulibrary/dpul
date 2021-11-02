# frozen_string_literal: true

# Override Spotlight::BulkActionsController to enable the `add_tags`,
# `remove_tags`, and `change_visibility` methods.
class BulkActionsController < Spotlight::BulkActionsController
  # Get solr params and remove group parameters. These were added to enable
  # search across and are incompatible with the Solr cursorMark used in the
  # Spotlight `each_document` method.
  # See: https://github.com/projectblacklight/spotlight/blob/v3.0.3/app/jobs/spotlight/add_tags_job.rb#L14
  # See: https://github.com/projectblacklight/spotlight/blob/v3.0.3/app/jobs/concerns/spotlight/gather_documents.rb#L10
  def solr_params
    solr_response.request_params.tap do |p|
      p.delete("group")
      p.delete("group.main")
      p.delete("group.facet")
      p.delete("group.limit")
      p.delete("group.field")
    end
  end
end
