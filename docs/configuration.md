# Contents

* [Architecture](architecture.md)
* Configuration
* [Database](database.md)
* [Event Relay](event_relay.md)
* [Events Creation](events_creation.md)
* [Failover](failover.md)
* [Message Producing](message_producing.md)
* [Monitoring](monitoring.md)

# Configuration

Before usage you've to configure the library. The library is not validating any configuration parameters right now but it can be implemented in future.

## Configuration example

```ruby
TransactionalOutbox.configure do |config|
  config.logger = Rails.logger
  config.outbox_table_name = "outbox_events"
  config.migrations_directory = Rails.root.join("db/migrate")
  config.default_event_builder = "TransactionalOutbox::Event::Builder"
  config.shutdown_waiting_time_seconds = 10

  config.db.adapter = :active_record
  config.db.connection_data = { model: "OutboxEvent" }

  config.producer.adapter = :kafka
  config.producer.connection_config = { seed_brokers: "localhost:9092" }

  config.relay.batch_size = 20
  config.relay.wait_between_batches_seconds = 0.1
  config.relay.failover = "TransactionalOutbox::Relay::Failover"
  config.relay.max_runner_retries_count = 5
  config.relay.delay_between_worker_set_processor_cycles = 1
end
```

## Configurable parameters

NOTE: **required** parameters should be defined in all cases and haven't any default value.

### Common parameters

* **required** `logger` - an instance of logger, the library uses only `info` and `error` logs levels. The parameter hasn't default value.
* **required in some cases** `migrations_directory` - a path to migrations directory, it uses when migrations are generating. Parameter is not mandatory while you aren't using the migration generator. Parameter hasn't default value.
* `outbox_table_name` - the name of outbox table. This parameter uses when the library is trying to query a database or generate migrations. Default value is `outbox_events`.
* `default_event_builder` - an event builder class. A builder defines a message broker event structure, you can see example [here](../transactional_outbox/event/bulder.rb). It can be overriden by an event configuration (see [Events Creation](events_creation.md)). Default value is `TransactionalOutbox::Event::Builder`
* `shutdown_waiting_time_seconds` - time (in seconds) to wait of graceful shutdown. When time is over a process doesn't wait while threads will stop at a safe point. Default value is `10`.

### Database parameters

* **required** `db.adapter` - a database adapter key. Possible values by default are `sequel` and `active_record`. You can define and register your own adapter by instructions [here](database.md). The parameter hasn't default value.
* **required in some cases** `db.connection_data` - a connection parameters. The parameter is mandatory for default adapters and hasn't default value. It should be a hash and contains:
  * **required for active record** `db.connection_data[:model]` - an outbox event model class. It has to be a string. The parameter is mandatory for `active_record` adapter and useless for `sequel`. It has no default value.
  * **required for sequel** `db.connection_data[:db]` - a sequel db instance (usual it's `Sequel::Model.db`). The parameter is mandatory for `sequel` adapter and useless for `active_record`. It has no default value.

**Example configuration for Sequel:**

```ruby
TransactionalOutbox.configure do |config|
  # Some parameters before

  config.db.adapter = :sequel
  config.db.connection_data = { db: Sequel::Model.db }

  # Some parameters after
end
```

**Example configuration for Active Record:**

```ruby
TransactionalOutbox.configure do |config|
  # Some parameters before

  config.db.adapter = :active_record
  config.db.connection_data = { model: "OutboxEvent" }

  # Some parameters after
end
```

### Producer parameters

* **required** `producer.adapter` - a producer adapter key. Possible value by default is only `kafka` (`ruby-kafka` gem). You can define and register your own adapter by instructions [here](message_producing.md). The parameter hasn't default value.
* **required** `producer.connection_config` - a connection config. It throws to initializer of an adapter instance. The parameter hasn't default value.

Example configuration for Kafka:

```ruby
TransactionalOutbox.configure do |config|
  # Some parameters before

  config.producer.adapter = :kafka
  config.producer.connection_config = { seed_brokers: "localhost:9092" }

  # Some parameters after
end
```

### Event Relay parameters

* `relay.batch_size` - a count of events fetching from a database. Default value is `20`.
* `relay.wait_between_batches_seconds` - time (in seconds) between processing previous and next batches. You can increase time for reducing queries count to database, but it affects a performance. Default value is `0.1`.
* `relay.failover` - an instance (or callable singleton class, or proc/lambda) of an event failover. It has to be a string. You can define there exceptions handling/failing events behaviour (see failover.md). By default the library doesn't handle any exceptions arising during an event processing, default failover just throws received exception. Default value is `TransactionalOutbox::Relay::Failover`.
* `max_runner_retries_count` - max attemps to process queues and spawn workers by event relay runner until it dies. Default value is `5`.
* `delay_between_worker_set_processor_cycles` - delay (in seconds) between spawn workers cycle (**fetch queues -> try to spawn workers for each of them**). Default value is `1`.
