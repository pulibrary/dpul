# frozen_string_literal: true

module Spotlight
  ##
  # Reindex the given resources or exhibits
  class ReindexJob < Spotlight::ApplicationJob
    queue_as :default

    include Spotlight::JobTracking
    include ::JobTracking
    # Princeton Update
    # We have tests that save resources that have no exhibit. If there's no
    # exhibit, this would error.
    with_job_tracking(resource: ->(job) { job.exhibit || Array(job.arguments.first).first })

    include Spotlight::LimitConcurrency

    before_perform do |job|
      progress.total = resource_list(job.arguments.first).count
    end

    after_perform do
      exhibit&.touch
    end

    after_perform :commit

    def perform(exhibit_or_resources, **)
      # make this a unique array of job ids
      errors = []

      error_handler = lambda do |pipeline, exception, _data|
        job_tracker.append_log_entry(
          type: :error,
          exhibit:,
          message: exception.to_s,
          backtrace: exception.backtrace.first(5).join("\n"),
          resource_id: (pipeline.source.id if pipeline.source.respond_to?(:id))
        )
        mark_job_as_failed!
        errors |= [job_id]
        raise exception
      end

      resource_list(exhibit_or_resources).each do |resource|
        resource.reindex(touch: false, commit: false, job_tracker:, additional_data: job_data, on_error: error_handler)

        # Increment progress outside of the reindex callback otherwise the count
        # is off. Not sure why.
        progress&.increment
      rescue StandardError => e
        error_handler.call(Struct.new(:source).new(resource), e, nil)
      ensure
        job_tracker.append_log_entry(
          type: :summary,
          exhibit:,
          message: I18n.t(
            'spotlight.job_trackers.show.messages.status.in_progress',
            progress: progress.progress,
            total: progress.total,
            errors: (I18n.t('spotlight.job_trackers.show.messages.errors', count: errors.count) if errors.present?)
          ),
          progress: progress.progress, total: progress.total, errors: errors.count
        )
      end
    end

    def exhibit
      exhibit_or_resources = arguments.first

      case exhibit_or_resources
      when Spotlight::Exhibit
        exhibit_or_resources
      when Spotlight::Resource
        exhibit_or_resources.exhibit
      end
    end

    private

      def commit
        Blacklight.default_index.connection.commit
      end

      def job_data
        return unless job_tracker

        @job_data ||= { Spotlight::Engine.config.job_tracker_id_field => job_tracker.top_level_job_tracker.job_id }
      end

      ## Princeton Update
      # Reindexing an exhibit should mean re-fetching all resources that are
      # part of the collection. ExhibitProxy enables this.
      def resource_list(exhibit_or_resources)
        if exhibit_or_resources.is_a?(Spotlight::Exhibit)
          [ExhibitProxy.new(exhibit_or_resources)]
        elsif exhibit_or_resources.is_a?(Enumerable)
          exhibit_or_resources
        else
          Array(exhibit_or_resources)
        end
      end
  end
end
