# frozen_string_literal: true

require "forwardable"

require "dry-container"
require "dry-configurable"
require "dry-validation"
require "json-schema"
require "oj"
require "securerandom"

require_relative "transactional_outbox/version"
require_relative "transactional_outbox/adapters/container"
require_relative "transactional_outbox/adapters/database"
require_relative "transactional_outbox/adapters/database/interface"
require_relative "transactional_outbox/adapters/database/null"
require_relative "transactional_outbox/adapters/database/active_record"
require_relative "transactional_outbox/adapters/database/sequel"
require_relative "transactional_outbox/adapters/producer"
require_relative "transactional_outbox/adapters/producer/interface"
require_relative "transactional_outbox/adapters/producer/null"
require_relative "transactional_outbox/adapters/producer/karafka"
require_relative "transactional_outbox/constants"
require_relative "transactional_outbox/database"
require_relative "transactional_outbox/event"
require_relative "transactional_outbox/event/message_builder"
require_relative "transactional_outbox/exceptions"
require_relative "transactional_outbox/exponential_backoff"
require_relative "transactional_outbox/producer"

require_relative "transactional_outbox/relay/runner"

TransactionalOutbox::Adapters::Database.register(:null, TransactionalOutbox::Adapters::Database::Null)
TransactionalOutbox::Adapters::Database.register(:sequel, TransactionalOutbox::Adapters::Database::Sequel)
TransactionalOutbox::Adapters::Database.register(:active_record, TransactionalOutbox::Adapters::Database::ActiveRecord)

TransactionalOutbox::Adapters::Producer.register(:null, TransactionalOutbox::Adapters::Producer::Null)
TransactionalOutbox::Adapters::Producer.register(:karafka, TransactionalOutbox::Adapters::Producer::Karafka)

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
  setting :default_message_builder, default: TransactionalOutbox::Event::MessageBuilder

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
