# Relay

The event relay is the process that reads events out of the outbox table and publishes them to the message broker. It's a separate long-running process from your application — you configure the library once (see [configuration](configuration.md)) and then start the relay as its own process alongside your app.

## Running it

Two ways are provided out of the box:

* the `bin/relay` executable:

```bash
bundle exec bin/relay
```

* a rake task, registered automatically for Rails apps via the gem's railtie:

```bash
bundle exec rake relay:run
```

Both just call [`TransactionalOutbox::Relay::Runner.start`](../lib/transactional_outbox/relay/runner.rb), which is the entry point if you want to embed it into your own process management instead:

```ruby
TransactionalOutbox::Relay::Runner.start
```

`Runner.start` publishes the `runner.init` [monitoring](monitoring.md) event, builds a `WorkerSet`, and hands it to the worker-set processor loop. It blocks the current thread/process until it shuts down (see below).

## Creating workers

Work is split by topic: one worker thread per topic, each independently fetching, producing and deleting its own batches of events. Workers are created and supervised by [`WorkerSet::Processor`](../lib/transactional_outbox/relay/worker_set/processor.rb), which loops forever:

1. Fetch the current distinct list of topics from the outbox table (`db.fetch_topics`).
2. For every topic: create a new worker if none exists yet (`WorkerSet#add_worker`), or try to recover it if one already exists but has stopped and isn't shutting down (`WorkerSet#try_to_recover_worker`) — this is what restarts a worker whose thread died.
3. Sleep for `relay.delay_between_worker_set_processor_cycles` seconds and repeat.

Creating a worker ([`WorkerSet::Worker`](../lib/transactional_outbox/relay/worker_set/worker.rb)) publishes the `worker.run` monitoring event and spawns a `Thread` that loops forever calling `EventProcessor.new(topic).call` — fetching a batch, producing it, deleting it, and going back to sleep for `relay.wait_between_batches_seconds`. Exceptions raised while processing a batch are sent to the configured [failover](failover.md) instead of killing the process outright.

If the processor loop itself raises (e.g. `db.fetch_topics` fails), it's retried in place with an exponential backoff (`2**retry_count` seconds) up to `relay.max_runner_retries_count` times before it gives up and re-raises, which is what triggers a shutdown of the whole runner.

## Graceful shutdown

`Runner.start` wraps the processor loop in `rescue StandardError` and `rescue SignalException` (which is what an interrupt like `Ctrl+C`/`SIGINT` raises). Either one triggers a shutdown:

```ruby
rescue StandardError => e
  shutdown(e, worker_set, 1)
rescue SignalException => e
  shutdown(e, worker_set, 0)
```

Shutdown logs the exception, then calls [`GracefulShutdown.call(worker_set)`](../lib/transactional_outbox/relay/graceful_shutdown.rb), which:

1. Signals every worker to stop (`worker_set.stop_workers`) — each worker finishes its current fetch/produce/delete cycle and then exits its loop, rather than being killed mid-batch.
2. Polls every `0.1` seconds, for up to `shutdown_waiting_time_seconds` (see [configuration](configuration.md)), waiting for `worker_set.all_stopped?` to become true.
3. If every worker stops in time, publishes the `runner.stopped` monitoring event and logs `"All workers have stopped."`.
4. If the timeout is reached first, shutdown proceeds anyway without waiting further — workers that are still finishing up may not get to complete their in-flight batch.

Finally, the process exits with code `1` if the shutdown was caused by an unhandled `StandardError`, or `0` if it was caused by a signal (a clean interrupt).
