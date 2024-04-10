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
      job_tracker.update(status: 'in_progress')
      exhibit = ExhibitProxy.new(exhibit)

      # Remove resources not currently in collection
      exhibit.members_to_remove_from_index.each(&:remove_from_solr)

      errored_resources = enqueue_resources(exhibit.resources)
      # do up to 5 retries
      5.times do
        break if errored_resources.blank?
        errored_resources = enqueue_resources(errored_resources)
      end
      return if errored_resources.blank?
      # errors after retries set failed status, with details sent to Honeybadger
      Honeybadger.notify("Exhibit index failure on #{exhibit.slug}, with timeout errors on #{errored_resources.map(&:url).join(', ')}")
      job_tracker.update(status: 'failed')
    end

    def enqueue_resources(resources_to_enqueue)
      errored_resources = []
      # Enqueue a reindex job for each member resource
      resources_to_enqueue.each do |resource|
        resource.save unless resource.persisted?
        # Don't reindex invalid resources - these are usually ones which are
        # private and the app can't download manifests for.
        Spotlight::ReindexJob.perform_later(resource, reports_on: job_tracker) if resource.valid?
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed
        # we've observed read timeout, but webmock to_timeout mocks open timeout
        errored_resources.push(resource)
      end
      errored_resources
    end

    # Used to calculate the total number of resources in the processed by the job
    def resource_list(exhibit)
      ExhibitProxy.new(exhibit).members
    end
  end
end
