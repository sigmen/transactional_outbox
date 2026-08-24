# Contents

* [Architecture](architecture.md)
* [Configuration](configuration.md)
* [Database](database.md)
* [Event Relay](event_relay.md)
* Events Creation
* [Failover](failover.md)
* [Message Producing](message_producing.md)
* [Monitoring](monitoring.md)

# Events Creation

An event is a class that describes one kind of outbox record: which topic it goes to, what its payload looks like, and how the incoming data should be validated before it's persisted. You declare one subclass per event/message type your application produces.

## Declaring an event

Subclass [`TransactionalOutbox::Event`](../lib/transactional_outbox/event.rb):

```ruby
class UserCreatedEvent < TransactionalOutbox::Event
  aggregate_type "user"
  event_type "created"
  topic "users"
  schema JSON.load_file(Rails.root.join("app/schemas/user_created.json"))

  context do
    required(:id).filled(:string)
    required(:name).filled(:string)
  end

  payload do |context|
    { id: context[:id], name: context[:name] }
  end
end
```

* `context` defines a [`dry-validation`](https://dry-rb.org/gems/dry-validation) contract (via `Event::Contextable`) that the hash passed to `create!`/`bulk_create!` must satisfy. It's optional — skip it if you don't need to validate the input.
* `payload` defines how to turn that context into the event's payload hash (via `Event::Payloadable`), evaluated with `instance_exec`, so you can call other instance methods from inside the block. It's also optional — without it the context itself is used as the payload verbatim.

## Configuring an event

These are `Dry::Configurable` settings (backed by `setting`), each exposed as a class-level macro:

* `topic` — the topic the event is produced to. Mandatory, no default.
* `aggregate_type` — an arbitrary string identifying the domain aggregate the event belongs to (e.g. `"user"`, `"order"`). Included in the built row. No default.
* `event_type` — the event's type within its aggregate (e.g. `"created"`, `"updated"`). No default.
* **optional** `schema` — a JSON schema (as a hash) the built payload is validated against with [`json-schema`](https://github.com/voxpupuli/json-schema) before saving. If left unset, payload validation is skipped entirely.
* **optional** `event_builder` — a class name (string) overriding [`default_event_builder`](configuration.md) for this event only. See "Custom builders" below.

## Using events in your application

```ruby
UserCreatedEvent.new.create!(id: user.id, name: user.name)
```

`create!(context)`:

1. Validates `context` against the `context` contract, raising `TransactionalOutbox::Exceptions::InvalidContextError` if it doesn't match.
2. Builds the payload from `context` (via the `payload` block, or the context itself if none was declared).
3. Validates the payload against `schema`, raising `TransactionalOutbox::Exceptions::InvalidPayloadError` if it doesn't match (skipped when `schema` is unset).
4. Builds the final row via the event builder and inserts it into the outbox table.

`bulk_create!(contexts)` does the same for an array of contexts, inserting all the resulting rows in a single insert.

Both simply insert into the outbox table — they don't open a transaction by themselves. To get the actual transactional-outbox guarantee (the event row committed atomically together with the business data change it describes), wrap the write with `TransactionalOutbox.transaction`:

```ruby
TransactionalOutbox.transaction(UserCreatedEvent) do |event|
  user = User.create!(name: params[:name])

  event.create!(id: user.id, name: user.name)
end
```

`TransactionalOutbox.transaction(event_class)` opens a database transaction through the configured [database adapter](database.md) and yields a new instance of `event_class`. As long as the rest of your business writes inside the block go through the same underlying connection (the `active_record`/`sequel` model configured in `db.connection_data`), they commit or roll back together with the outbox insert.

### Custom builders

By default, rows are built by [`TransactionalOutbox::Event::Builder`](../lib/transactional_outbox/event/builder.rb):

```ruby
def self.build(event_config, payload, _context)
  {
    id: SecureRandom.uuid,
    topic: event_config.topic,
    aggregate_type: event_config.aggregate_type,
    event_type: event_config.event_type.to_s,
    headers: {},
    payload:
  }
end
```

To customize the shape of the row (e.g. add headers), implement your own class with the same `self.build(event_config, payload, context)` signature returning a hash matching your outbox table's columns, and either set it globally via `config.default_event_builder` (see [configuration](configuration.md)) or per event via `event_builder "MyApp::CustomBuilder"`.
