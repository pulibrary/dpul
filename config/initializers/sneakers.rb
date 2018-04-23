require 'sneakers'
require 'sneakers/handlers/maxretry'
require_relative 'pom_config'
Sneakers.configure(
  amqp: Pomegranate.config["events"]["server"],
  exchange: Pomegranate.config["events"]["exchange"],
  exchange_type: :fanout,
  handler: Sneakers::Handlers::Maxretry,
  timeout_job_after: 300
)
Sneakers.logger.level = Logger::INFO

WORKER_OPTIONS = {
  ack: true,
  threads: 5,
  prefetch: 10,
  timeout_job_after: 300,
  heartbeat: 5,
  amqp_heartbeat: 10,
  retry_timeout: 300 * 1000 # 5 minutes
}.freeze
