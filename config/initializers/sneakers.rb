require 'sneakers'
require_relative 'pom_config'
Sneakers.configure(
  amqp: Pomegranate.config["events"]["server"],
  exchange: Pomegranate.config["events"]["exchange"],
  exchange_type: :fanout
)
Sneakers.logger.level = Logger::INFO
