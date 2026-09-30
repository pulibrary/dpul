# frozen_string_literal: true

class FiggyEventHandler
  include Sneakers::Worker
  from_queue :"pomegranate_#{Rails.env}",
             WORKER_OPTIONS.merge(
               arguments: { 'x-dead-letter-exchange': "pomegranate_#{Rails.env}-retry" }
             )

  def work(msg)
    ActiveRecord::Base.connection.verify!
    ProcessEventJob.perform_later(msg)
    ack!
  end
end
