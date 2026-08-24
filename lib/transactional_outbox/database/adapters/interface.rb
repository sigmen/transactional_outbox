# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class Interface
        def initialize
          @outbox_table_name = TransactionalOutbox.config.outbox_table_name
        end

        def transaction(*_options, &) = raise NotImplementedError
        def insert_events(_attributes) = raise NotImplementedError
        def fetch_events(_queue_name) = raise NotImplementedError
        def delete_events(_ids) = raise NotImplementedError
        def fetch_queues = raise NotImplementedError

        private

        attr_reader :outbox_table_name

        def config = @config ||= TransactionalOutbox.config
      end
    end
  end
end
