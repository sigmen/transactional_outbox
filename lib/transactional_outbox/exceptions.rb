# frozen_string_literal: true

module TransactionalOutbox
  module Exceptions
    class UnsupportedEventType < StandardError; end
    class UnsupportedAdapter < StandardError; end
    class InvalidPayloadError < StandardError; end
  end
end
