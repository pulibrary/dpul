class PlumEventHandler
  include Sneakers::Worker
  from_queue :pomegranate,
             WORKER_OPTIONS.merge(
               arguments: { 'x-dead-letter-exchange': 'pomegranate-retry' }
             )

  def work(msg)
    msg = JSON.parse(msg)
    result = PlumEventProcessor.new(msg).process
    if result
      ack!
    else
      reject!
    end
  end
end
