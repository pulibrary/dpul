# frozen_string_literal: true

# Overrides a handful of Spotlight JobTacking concern methods to allow accurate
# tracking of Princeton exhibit reindex jobs
# See: https://github.com/projectblacklight/spotlight/blob/v3.0.3/app/jobs/concerns/spotlight/job_tracking.rb
module JobTracking
  extend ActiveSupport::Concern
  include ActiveJob::Status

  class_methods do
    # Override to initialize the job tracker on enqueue so that that the total
    # number of tracked jobs is known upfront. Improves the quality of metrics
    # displayed to the user.
    def with_job_tracking(
      resource:,
      reports_on: ->(job) { job.arguments.last[:reports_on] if job.arguments.last.is_a?(Hash) },
      user: ->(job) { job.arguments.last[:user] if job.arguments.last.is_a?(Hash) }
    )
      around_enqueue do |job, block|
        resource_object = resource&.call(job)

        job.initialize_job_tracker!(
          resource: resource_object,
          on: reports_on&.call(job) || resource_object,
          user: user&.call(job),
          data: { progress: 0, total: total_resources }
        )

        block.call
      end

      around_perform do |job, block|
        resource_object = resource&.call(job)

        job.initialize_job_tracker!(
          resource: resource_object,
          on: reports_on&.call(job) || resource_object,
          user: user&.call(job),
          data: { progress: 0, total: total_resources }
        )

        block.call
      ensure
        job.finalize_job_tracker!
      end
    end
  end

  private

    # Get total number of resources processed by the job.
    def total_resources
      resource_list(arguments.first).count
    end
end
