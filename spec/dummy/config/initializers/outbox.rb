TransactionalOutbox.configure do |config|
  config.logger = Logger.new($stdout)
  config.outbox_table_name = "outbox_events"
  config.migrations_directory = Rails.root.join("db/migrations")
  config.default_event_builder = "Outbox::Events::Builder"
  config.test_environment = true

  config.db.adapter = :sequel
  config.producer.adapter = :kafka
  config.producer.client = Kafka.new("localhost")
end
