For more background see [the relevant architecture decision record](https://github.com/pulibrary/pomegranate/blob/master/architecture-decisions/0003-synchronization-via-rabbitmq.md)

Capistrano's worker restart runs tasks for both sidekiq and sneakers workers.

Every message sent to the figgy_events fanout exchange is copied to every queue attached to that exchange. Figgy configures the exchange and other applications configure the queues.

Configuration:
  * In Figgy, exchanges are configured in `app/services/messaging_client.rb` (there are others here for other consumer apps). It uses a gem called `bunny`. The exchanges are durable. This means they will come back after a rabbitmq crash. (note that the messages aren't created as "persistent" which means they would be lost in a rabbitmq crash.)
  * In pomegranate, general configuration is in `config/initializers/sneakers.rb`. The exchange here has to match the one configured in figgy.
  * The queue to use is defined in `app/workers/figgy_event_handler.rb`. The queue is durable except in staging. The staging site gets swapped back and forth between figgy-staging and figgy-prod, and we don't need it to keep stacking up messages on the rabbitmq instance it's not connected to.

If you need to look at a message from the queue, you can pull it out and set it to nack / requeue, that way it will go back on the queue after you have retrieved it
  * In figgy use the cap task `cap production rabbitmq:console` to launch rabbitmq (vpn required; find password in ansible vault)
  * Go to queues > select queue > click "get message" (ack mode should be "Nack
message requeue true")

When you get it the payload may be base64 encoded (although I'm not seeing this anymore). You can cut / paste it into irb and do `Base64.decode64(payload)` to see the details of the message. The properties is also base64 encoded.