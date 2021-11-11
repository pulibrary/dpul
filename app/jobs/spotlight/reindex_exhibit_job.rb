# frozen_string_literal: true

# Override to enable Princeton-style exhibit indexing
# See: https://github.com/projectblacklight/spotlight/blob/v3.0.3/app/jobs/spotlight/reindex_exhibit_job.rb
module Spotlight
  ##
  # Reindex an exhibit by parallelizing resource indexing into multiple batches of reindex jobs
  class ReindexExhibitJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking
    include ::JobTracking
    with_job_tracking(resource: ->(job) { job.arguments.first })

    include Spotlight::LimitConcurrency

    before_perform do |job|
      progress.total = resource_list(job.arguments.first).count
    end

    def perform(exhibit, **)
      exhibit = ExhibitProxy.new(exhibit)

      # Remove resources not currently in collection
      exhibit.members_to_remove_from_index.each(&:remove_from_solr)

      # Enqueue a reindex job for each member resource
      exhibit.resources.each do |resource|
        Spotlight::ReindexJob.perform_later(resource, reports_on: job_tracker)
      end

      job_tracker.update(status: 'in_progress')
    end

    # Used to calculate the total number of resources in the processed by the job
    def resource_list(exhibit)
      ExhibitProxy.new(exhibit).members
    end
  end
end
