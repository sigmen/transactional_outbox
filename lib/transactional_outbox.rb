# frozen_string_literal: true

require "dry-configurable"
require "json-schema"

require_relative "transactional_outbox/version"
require_relative "transactional_outbox/constants"
require_relative "transactional_outbox/event"
require_relative "transactional_outbox/exceptions"

module TransactionalOutbox
  extend Dry::Configurable

  setting :db do
    setting :adapter
    setting :connection
  end

  include Exceptions

  def self.transaction(event)
    Database.transaction do
      yield(event)
    end
  end
end
