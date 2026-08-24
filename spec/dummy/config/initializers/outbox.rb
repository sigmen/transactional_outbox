# frozen_string_literal: true

TransactionalOutbox.configure do |config|
  config.logger = Logger.new($stdout)
  config.outbox_table_name = "outbox_events"
  config.migrations_directory = Rails.root.join("db/migrations")
  config.default_event_builder = "Outbox::Events::Builder"
  config.test_environment = true
  config.relay.max_runner_retries_count = 1
  config.relay.delay_between_worker_set_processor_cycles = 0.1

  config.db.adapter = :sequel
  config.db.connection_data = { db: Sequel::Model.db }
  config.producer.adapter = :kafka
  config.producer.connection_config = { seed_brokers: "localhost:9092" }
end
