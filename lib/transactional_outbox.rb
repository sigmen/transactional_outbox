# frozen_string_literal: true

require "forwardable"

require "dry-container"
require "dry-configurable"
require "json-schema"
require "oj"

require_relative "transactional_outbox/version"
require_relative "transactional_outbox/constants"
require_relative "transactional_outbox/database"
require_relative "transactional_outbox/database/adapters"
require_relative "transactional_outbox/database/adapters/interface"
require_relative "transactional_outbox/database/adapters/null"
require_relative "transactional_outbox/database/adapters/active_record"
require_relative "transactional_outbox/database/adapters/sequel"
require_relative "transactional_outbox/event"
require_relative "transactional_outbox/exceptions"
require_relative "transactional_outbox/exponential_backoff"
require_relative "transactional_outbox/repositories/outbox_event"
require_relative "transactional_outbox/producer"
require_relative "transactional_outbox/producer/adapters"
require_relative "transactional_outbox/producer/adapters/interface"
require_relative "transactional_outbox/producer/adapters/null"
require_relative "transactional_outbox/producer/adapters/karafka"

require_relative "transactional_outbox/relay/runner"

TransactionalOutbox::Database::Adapters.register(:null, TransactionalOutbox::Database::Adapters::Null)
TransactionalOutbox::Database::Adapters.register(:sequel, TransactionalOutbox::Database::Adapters::Sequel)
TransactionalOutbox::Database::Adapters.register(:active_record, TransactionalOutbox::Database::Adapters::ActiveRecord)

TransactionalOutbox::Producer::Adapters.register(:null, TransactionalOutbox::Producer::Adapters::Null)
TransactionalOutbox::Producer::Adapters.register(:karafka, TransactionalOutbox::Producer::Adapters::Karafka)

module TransactionalOutbox
  include Exceptions

  extend Dry::Configurable

  setting :logger
  setting :metrics
  setting :outbox_table_name, default: "outbox_events"
  setting :batch_size, default: 20
  setting :wait_between_batches_seconds, default: 0.1
  setting :shutdown_waiting_time_seconds, default: 10
  setting :migrations_directory
  setting :test_environment, default: false
  setting :max_relay_runner_retries_count, default: 5

  setting :db do
    setting :adapter
  end

  setting :producer do
    setting :adapter
    setting :client
  end

  def self.transaction(event)
    Database.new.transaction do
      yield(event.new)
    end
  end
end
