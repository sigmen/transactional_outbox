# frozen_string_literal: true

module TransactionalOutbox
  module Exceptions
    class UnsupportedEventType < StandardError; end
    class UnsupportedDatabaseAdapter < StandardError; end
    class UnsupportedMessageBrokerAdapter < StandardError; end
    class InvalidPayloadError < StandardError; end
  end
end
