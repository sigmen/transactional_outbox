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

`TransactionalOutbox::Event` is a class that describes an event: which topic it goes to, what its payload looks like, and how the incoming data should be validated before it's persisted. You've to declare one event per each event type.

## Declaring an event

You need to inherit your event class from `TransactionalOutbox::Event`(../lib/transactional_outbox/event.rb). Inside it you've to declare next attributes:
* **required** `aggregate_type` - a type of an aggregate. Usually it's a snakecased event class name, but you are free to put anything there.
* **required** `event_type` - a type of an event which can identify what's happened with an aggregate or an entity. We recommend to use synonyms on data manipulations actions like created/updated/deleted, but you are free to put anything there.
* **required** `topic` - a topic name where you need to put an event at end of processing.
* `schema` - a schema object for a payload validation. Must be a hash and compatible with [json schema](https://json-schema.org). If a value is `nil` the validation will be skipped otherwise if the payload is not valid it raises `TransactionalOutbox::Exceptions::InvalidPayloadError` error.
* `event_builder` - an event builder class, see below how to implement it.

Also you can define `context` and `payload` blocks:
* **required** The `prepare_payload` block is needed for define an event payload. Inside this block you need to specify an payload structure. If a block is not defined it returns an input itself.
* The `context` block is needed for an input validation (attributes which received in `#Event.create!` method). For a correct behaviour you have to define it using [dry-schema](https://hanakai.org/learn/dry/dry-schema) DSL. It'a an optional attribute and if you will put there nothing - nothing will be validated. It raises `TransactionalOutbox::Exceptions::InvalidContextError` error if an input doesn't match with a contract.

```ruby
module Outbox
  module Events
    module User
      class CreatedEvent < TransactionalOutbox::Event
        aggregate_type "user"
        event_type "created"
        topic "users"
        schema SchemaRegistryCache.get_schema("user")
        event_builder MyEventBuilder

        context do
          required(:user).hash do
            required(:id).filled(:string)
            required(:name).filled(:string)
          end
        end

        prepare_payload do |context|
          { user: prepare_user(context) }
        end

        private

        def prepare_user(context)
          context[:user] => { id:, name: }

          { id:, name:}
        end
      end
    end
  end
end
```

## Create an event

For create an event you need to call `#create!(context)` on instance of event. When you call it the logic inside the event:

1. Validates `context` against the `context` contract (defined in a `context` block).
2. Prepare the payload using the `prepare_payload` block.
3. Validates the payload against `schema`.
4. Builds the final row via the event builder and inserts it into the outbox table.

The event class also implements `bulk_create!(contexts)` method, it does the same but receives array of contexts and using for batch insert.

Both simply insert into the outbox table — they don't open a transaction by themselves. To get the actual transactional-outbox guarantee (the event row committed atomically together with the business data change it describes), wrap the write with `TransactionalOutbox.transaction`:

```ruby
class CreateUserService
  def call(params)
    TransactionalOutbox.transaction(UserCreatedEvent) do |event|
      user = User.create!(name: params[:name])
      context = { user: }

      event.create!(context)
    end
  end
```

`TransactionalOutbox.transaction(event_class)` opens a database transaction through the configured [database adapter](database.md) and yields a new instance of `event_class`. As long as the rest of your business writes inside the block go through the same underlying connection (the `active_record`/`sequel` model configured in `db.connection_data`), they commit or roll back together with the outbox insert.

### Custom builders

By default, rows are built by [`TransactionalOutbox::Event::Builder`](../lib/transactional_outbox/event/builder.rb). To customize the shape of the row (e.g. add headers or version), implement your own class with the same definition of singleton method `#build` returning a hash matching your outbox table's columns, and either set it globally via [config.default_event_builder](configuration.md)) or per event via `event_builder "MyApp::CustomBuilder"`.
