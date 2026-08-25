# Introduction

`transactional_outbox` is a thread-safe implementation of the transactional outbox patter. There are both an event creation and an event relay functionality. **It doesn't require Rails.**

## Requirements

`ruby >= 3.2`

## Installation

1. Add this line to your application's Gemfile:

```ruby
gem 'transactional_outbox'
```

2. Execute:

    $ bundle install

Or install it yourself as:

    $ gem install transactional_outbox

## Using

1. Configure it (see [configuration](docs/configuration.md)).

2. Generate migrations (if you're using Rails) or use template from [here](./lib/generators/transactional_outbox/migration/templates/) and migrate it:

```sh
$ rails g transactional_outbox:migration
$ rails db:migrate
```

3. Define your own events (see [events creation](./docs/events_creation.md)).

4. Run event relay (see [event relay](./docs/event_relay.md)) with rake task (if needed):

```sh
$ rake event_relay:run
```

Or run it directly like [here](./examples/example-app/bin/relay):

```ruby
TransactionalOutbox::Relay::Runner.start
```

## Architecture

![Architecture](docs/architecture.png)

## Documentation

[Documentation](docs/contents.md)

## Contributing

Bug reports and pull requests are welcome [here](https://github.com/sigmen/transactional_outbox). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sigmen/transactional_outbox/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TransactionalOutbox project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sigmen/transactional_outbox/blob/main/CODE_OF_CONDUCT.md).
