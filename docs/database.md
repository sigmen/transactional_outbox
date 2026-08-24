# Contents

* [Architecture](architecture.md)
* [Configuration](configuration.md)
* Database
* [Event Relay](event_relay.md)
* [Events Creation](events_creation.md)
* [Failover](failover.md)
* [Message Producing](message_producing.md)
* [Monitoring](monitoring.md)

# Database

The library needs to fetch and manipulate data in outbox events table. Data can be stored in different storages or you can use (or not) any another ORM's instead of active record or sequel. For supporting this in the library implemented adapters system, it helps you to implement any behavior of communication with a data storage.
The library picks an adapter by the key configured in `db.adapter` (see [configuration](configuration.md)), resolves it from the registry and instantiates it.

**NOTE**: For idempotency purposes and avoiding concurrent access to data it has to support locks or same functionality.

It has two adapters by default:

* `sequel` — [`TransactionalOutbox::Database::Adapters::Sequel`](../lib/transactional_outbox/database/adapters/sequel.rb).
* `active_record` — [`TransactionalOutbox::Database::Adapters::ActiveRecord`](../lib/transactional_outbox/database/adapters/active_record.rb).

**NOTE**: There's also a `null` adapter ([`TransactionalOutbox::Database::Adapters::Null`](../lib/transactional_outbox/database/adapters/null.rb)) that stores events in memory. It's used for test/development environments instead of the configured adapter when configuration parameter `test_environment` is set to `true`.

## Writing your own adapter

1. Implement a class that inherits `TransactionalOutbox::Database::Adapters::Interface`. An adapter must implement the following methods (see [`Interface`](../lib/transactional_outbox/database/adapters/interface.rb)):
    * `transaction(*options, &block)` — runs `block` inside a database transaction.
    * `insert_events(attributes)` — bulk-inserts events (an array of hashes).
    * `fetch_events(topic_name, batch_size)` — returns array of events (hashes) up to `batch_size` rows for `topic_name`. Should lock the selected events (e.g. `FOR UPDATE SKIP LOCKED`) for concurrent workers couldn't pick up the same events.
    * `fetch_topics` — returns the unique list of topics currently present in the outbox table.
    * `delete_events(ids)` — deletes the events by the given ids.

Example:

```ruby
module Outbox
  module Database
    class CustomAdapter < TransactionalOutbox::Database::Adapters::Interface
      def initialize
        super

        @table_object = config.db.connection_data[:client].table(@outbox_events_table)
      end

      def transaction(*options, &block) = table_object.transaction(*options, &block)
      def insert_events(attributes) = table_object.insert(attributes)
      def fetch_topics = table_object.select(:topic).distinct

      def fetch_events(topic_name, batch_size)
        table_object.where(topic: topic_name).order(:created_at).lock.skip_locked.limit(batch_size)
      end

      def delete_events(ids) = table_object.delete(id: ids)

      private

      attr_reader :table_object
    end
  end
end
```

2. Register it under your own key:

```ruby
TransactionalOutbox::Database::Adapters.register(:custom_adapter, Outbox::Database::CustomAdapter)
```

`TransactionalOutbox::Database::Adapters#register` raises `TransactionalOutbox::AdapterAlreadyExistsError` if the key is already taken, so pick a key that doesn't collide with default adapters.

3. Then set it into config:

```ruby
TransactionalOutbox.configure do |config|
  config.db.adapter = :custom_adapter
  config.db.connection_data = { client: MyCustomDbClient.new }
end
```
