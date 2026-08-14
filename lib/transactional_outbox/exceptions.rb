# frozen_string_literal: true

module TransactionalOutbox
  module Exceptions
    class UnsupportedEventType < StandardError; end
    class InvalidPayloadError < StandardError; end
    class UnknownDatabaseAdapter < StandardError; end
    class UnknownProducerAdapter < StandardError; end
  end
end
