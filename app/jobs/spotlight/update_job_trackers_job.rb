# frozen_string_literal: true

module Spotlight
  class UpdateJobTrackersJob < Spotlight::ApplicationJob
    # Override to ensure that job is always run synchronously.
    # See: https://github.com/pulibrary/dpul/issues/1295
    def self.perform_later(job_tracker)
      perform_now(job_tracker)
    end

    def perform(job_tracker)
      reports_on = job_tracker.on

      return unless reports_on.is_a? Spotlight::JobTracker

      reports_on.update(status: 'completed') if reports_on.job_trackers.all?(&:completed?)
      reports_on.update(status: 'failed') if reports_on.job_trackers.any?(&:failed?)

      reports_on.update(data: { progress: reports_on.job_trackers.sum(&:progress), total: reports_on.job_trackers.sum(&:total) })
    end
  end
end
