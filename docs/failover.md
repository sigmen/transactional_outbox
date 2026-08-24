# Contents

* [Architecture](architecture.md)
* [Configuration](configuration.md)
* [Database](database.md)
* [Event Relay](event_relay.md)
* [Events Creation](events_creation.md)
* Failover
* [Message Producing](message_producing.md)
* [Monitoring](monitoring.md)

# Failover

## Purpose

`TransactionalOutbox::Relay::Failover` is the error handler invoked whenever an [`EventProcessor`](../lib/transactional_outbox/relay/event_processor.rb) fails to process a batch of events for a topic (e.g. the producer can't reach the broker, or the database is unavailable).

Each worker thread runs an infinite loop that calls events batch processor on every cycle. Inside event processor everything is wrapped in a `rescue StandardError`, and the raised exception (together with the batch of events being processed) is forwarded to the configured failover. The [default implementation](../transactional_outbox/relay/failover.md) just re-raises the exception.

## Writing your own failover

Implement a class (or any object) that responds to `#call(exception, events)` and configure it at [configuration](configuration.md) (**see relay.failover**). The configuration parameter accepts a string with the class name or any callable object (proc/lambda).

A failover only needs to respond to `#call` method which got two arguments:

* `exception` — the error class instance raised while processing the batch.
* `events` — the batch of raw event records that was being processed.

### Example

```ruby
module Outbox
  class Failover
    def self.call(exception, events)
      ids = events&.map { |e| e[:id] }

      OutboxEventRepository.new.fail_events_batch(ids)

      Sentry.capture_exception(exception)
    end
  end
end
```
