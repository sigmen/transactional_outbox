# Contents

* [Architecture](architecture.md)
* [Configuration](configuration.md)
* [Database](database.md)
* Event Relay
* [Events Creation](events_creation.md)
* [Failover](failover.md)
* [Message Producing](message_producing.md)
* [Monitoring](monitoring.md)


# Event Relay

The event relay is the process that reads events out of the outbox table and publishes them to the message broker. It's a separate long-running process from your application — you configure the library once (see [configuration](configuration.md)) and then start the relay as its own process alongside your app.

## Running

You can run it using rake task provided by the library (registered automatically for Rails apps):

```bash
bundle exec rake event_relay:run
```

It just calls `#TransactionalOutbox::Relay::Runner.start`. Runner publishes the `runner.init` [monitoring](monitoring.md) event, builds a worker set and hands it to the worker-set processor loop. It blocks the current thread/process until it shuts down (see below).

## Creating workers

Worker creates once per each queue, each independently fetching, producing and deleting its own batches of events. Workers are created and supervised by [processor](../lib/transactional_outbox/relay/worker_set/processor.rb), which loops forever:

1. Fetch the current distinct list of queues from the outbox table.
2. For every queue: create a new worker if none exists yet (`WorkerSet#add_worker`), or try to recover it (by replacing to new one) if it is not died by graceful shutdown.
3. Sleep for[relay.delay_between_worker_set_processor_cycles](configuration.md) seconds and repeat.

Creating a worker ([WorkerSet::Worke`](../lib/transactional_outbox/relay/worker_set/worker.rb)) it publishes the `worker.run` monitoring event and spawns a thread that loops calling event processor which fetching a batch (**with row-level locks**), producing it, deleting it, and waiting for the next iteration (see [relay.wait_between_batches_seconds](configuration.md)). Exceptions raised while processing a batch are sent to the configured [failover](failover.md) instead of killing the process outright and send the [worker.exception_total](monitoring.md) monitoring metric. If the processor loop itself raises (e.g. database query fails with error), it's retried in place with an exponential backoff up to [relay.max_runner_retries_count](configuration.md) times before it gives up and starts graceful shutdown.

## Graceful shutdown

Runner wraps the processor loop and rescues `StandardError` and `SignalException`. Shutdown logs the exception, then starts [graceful shutdown](../lib/transactional_outbox/relay/graceful_shutdown.rb), which:

1. Signals every worker to stop (`worker_set.stop_workers`) — each worker finishes its current fetch/produce/delete cycle and then exits its loop, rather than being killed mid-batch.
2. Checks that every worker has been stopped until [shutdown_waiting_time_seconds](configuration.md) is over.
3. If every worker stops in time, publishes the `runner.stopped` monitoring event.
4. If the timeout is reached first, shutdown proceeds anyway without waiting further — workers that are still finishing up may not get to complete their in-flight batch.

Finally, the process exits with code `1` if the shutdown was caused by an unhandled `StandardError`, or `0` if it was caused by a signal (a clean interrupt).
