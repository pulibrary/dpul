class PlumEventHandler
  include Sneakers::Worker
  from_queue :pomegranate,
             WORKER_OPTIONS.merge(
               arguments: { 'x-dead-letter-exchange': 'pomegranate-retry' }
             )

  def work(msg)
    msg = JSON.parse(msg)
    PlumEventProcessor.new(msg).process
    ack!
  end
end
