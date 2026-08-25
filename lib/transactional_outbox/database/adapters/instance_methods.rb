# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      module InstanceMethods
        def initialize
          @outbox_table_name = TransactionalOutbox.config.outbox_table_name
        end

        private

        attr_reader :outbox_table_name

        def config = @config ||= TransactionalOutbox.config
        def outdated_events_timestamp = Time.now.utc - config.relay.processing_events_claim_timeout_seconds
        def current_time = Time.now.utc
      end
    end
  end
end
