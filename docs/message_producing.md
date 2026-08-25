# Contents

* [Architecture](architecture.md)
* [Configuration](configuration.md)
* [Database](database.md)
* [Event Relay](event_relay.md)
* [Events Creation](events_creation.md)
* [Failover](failover.md)
* Message Producing
* [Monitoring](monitoring.md)

# Producer

The library has one adapter by default:

* `kafka` — [`TransactionalOutbox::Producer::Adapters::Kafka`](../lib/transactional_outbox/producer/adapters/kafka.rb).

NOTE: There's also a `null` adapter ([`TransactionalOutbox::Producer::Adapters::Null`](../lib/transactional_outbox/producer/adapters/null.rb)) that stores produced events in memory instead of sending them anywhere. It's used for test/development environments instead of the configured adapter when configuration parameter `test_environment` is set to `true`.

## Writing your own adapter

1. Implement a class that inherits `TransactionalOutbox::Producer::Adapters::Interface`. An adapter must implement the following method (see [`Interface`](../lib/transactional_outbox/producer/adapters/interface.rb)):
    * `produce_batch(queue, batch)` — publishes `batch` (an array of events) to `queue`.
    * `close` - closes a connection.

The interface's `initialize` accepts a `connection_config` and exposes it as a private `connection_config` reader.

Example:

```ruby
module Outbox
  module Producer
    class CustomAdapter < TransactionalOutbox::Producer::Adapters::Interface
      def produce_batch(queue, batch)
        client.publish_many(queue, events.to_json)
      end
    end
  end
end
```

2. Register it under your own key:

```ruby
TransactionalOutbox::Producer::Adapters.register(:custom_adapter, Outbox::Producer::CustomAdapter)
```

`TransactionalOutbox::Producer::Adapters#register` raises `TransactionalOutbox::AdapterAlreadyExistsError` if the key is already taken, so pick a key that doesn't collide with default adapters.

3. Then set it into config:

```ruby
TransactionalOutbox.configure do |config|
  config.producer.adapter = :custom_adapter
  config.producer.connection_config = { seed_brokers: "localhost:9092" }
end
```
