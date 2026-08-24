# frozen_string_literal: true

TransactionalOutbox.configure do |config|
  config.logger = Rails.logger
  config.outbox_table_name = "outbox_events"
  config.migrations_directory = Rails.root.join("db/migrate")
  config.default_event_builder = "TransactionalOutbox::Events::Builder"
  config.shutdown_waiting_time_seconds = 10

  config.db.adapter = :active_record
  config.db.connection_data = { model: "OutboxEvent" }

  config.producer.adapter = :kafka
  config.producer.client = Kafka.new(seed_brokers: "localhost:9092")

  config.relay.batch_size = 20
  config.relay.wait_between_batches_seconds = 0.1
  config.relay.failover = "Outbox::Failover"
  config.relay.max_runner_retries_count = 5
  config.relay.delay_between_worker_set_processor_cycles = 1
end

Rails.application.config.after_initialize do
  TransactionalOutbox.monitor.subscribe(TransactionalOutbox::RUNNER_INIT_MONITOR_EVENT) do
    FileUtils.touch("/tmp/outbox")
  end
end
