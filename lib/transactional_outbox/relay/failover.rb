# frozen_string_literal: true

module TransactionalOutbox
  module Relay
    class Failover
      def self.call(exception, _worker) = raise exception
    end
  end
end
