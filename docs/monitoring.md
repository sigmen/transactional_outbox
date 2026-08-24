# Contents

* [Architecture](architecture.md)
* [Configuration](configuration.md)
* [Database](database.md)
* [Event Relay](event_relay.md)
* [Events Creation](events_creation.md)
* [Failover](failover.md)
* [Message Producing](message_producing.md)
* Monitoring

# Monitoring

## Monitor

The library publishes events to a monitor for further processing and metric recording on the application layer. You can use any metrics adapter which you prefer and register events there using `#TransactionalOutbox::Relay.monitor.subscribe` method. You can have access to an event attributes using `event#id` method for getting event type and `event#payload` for getting event payload. It publishes next event types:
* `runner.init` — published once when `Relay::Runner` starts up. Payload doesn't exist.
* `runner.stopped` — published after all workers have gracefully stopped during shutdown. Payload doesn't exist.
* `worker.run` — published when a worker thread is spawned for a topic. Payload key is only `topic` (worker's topic).
* `worker.events.processed` — published after a worker successfully produces and deletes a batch of events. Payload keys are `topic` (worker's topic), `count` (processed events count). If event processing raises an error, `worker.events.processed` is not published for that cycle — the exception goes to the configured [failover](failover.md) instead.
* `worker.stopped` — published when a worker thread stops. Payload key is only `topic` (worker's topic).
* `worker.exceptions_total` — published whenever `EventProcessor#call` rescues a `StandardError` while fetching/producing/deleting events, right before it's forwarded to the configured [failover](failover.md). Payload keys are `topic` (worker's topic), `exception` (the exception's class).

### Subscription example (worker.events.processed)

```ruby
TransactionalOutbox::Relay.monitor.subscribe("worker.events.processed") do |event|
  metrics = Yabeda.your_app = # Your custom metrics registry
  tags = { topic: event.payload[:topic] }

  metrics.worker.events_processed.set(tags, by: event.payload[:count])
end
```
