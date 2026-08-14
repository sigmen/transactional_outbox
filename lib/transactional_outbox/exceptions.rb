# frozen_string_literal: true

module TransactionalOutbox
  module Exceptions
    class UnsupportedEventTypeError < StandardError; end
    class InvalidPayloadError < StandardError; end
    class UnknownDatabaseAdapterError < StandardError; end
    class UnknownProducerAdapterError < StandardError; end
    class ImpossibleToGenerateMigrationError < StandardError; end
  end
end
