# frozen_string_literal: true

require "forwardable"

require "async"
require "dry-configurable"
require "json-schema"
require "oj"

require_relative "transactional_outbox/version"
require_relative "transactional_outbox/constants"
require_relative "transactional_outbox/event"
require_relative "transactional_outbox/exceptions"
require_relative "transactional_outbox/database"
require_relative "transactional_outbox/producer"

require_relative "transactional_outbox/relay/processor"

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

  setting :db do
    setting :adapter
    setting :connection
  end

  setting :producer do
    setting :adapter
    setting :producer
  end

  def self.transaction(event)
    Database.transaction do
      yield(event.new)
    end
  end
end
