# frozen_string_literal: true

Rails.application.config.to_prepare do
  module JobTrackingPatch
    # Overrode this to do find_or_initialize_by - this may be broken upstream.
    # See: https://github.com/projectblacklight/spotlight/issues/2777
    # Needed for Spotlight::ReindexJob and Spotlight::ReindexExhibitJob
    def find_or_initialize_job_tracker
      Spotlight::JobTracker.find_or_initialize_by(job_id:) do |tracker|
        tracker.job_class = self.class.name
        tracker.status = "enqueued"
      end
    end
  end

  Spotlight::JobTracking.prepend(JobTrackingPatch)
end
