# frozen_string_literal: true

module TransactionalOutbox
  module Exceptions
    class UnsupportedEventTypeError < StandardError; end
    class InvalidPayloadError < StandardError; end
    class UnknownAdapterError < StandardError; end
    class AdapterAlreadyExistsError < StandardError; end
    class ImpossibleToGenerateMigrationError < StandardError; end
    class InvalidContextError < StandardError; end
  end
end
