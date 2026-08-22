# frozen_string_literal: true

module TransactionalOutbox
  class Relay
    class Failover
      def self.call(exception, _events) = raise exception
    end
  end
end
