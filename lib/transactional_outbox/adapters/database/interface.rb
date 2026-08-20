# frozen_string_literal: true

module TransactionalOutbox
  module Adapters
    class Database
      class Interface
        def initialize
          @outbox_table_name = TransactionalOutbox.config.outbox_table_name
        end

        def transaction(*_options, &) = raise NotImplementedError
        def insert_events(_attributes) = raise NotImplementedError
        def fetch_events(_topic_name) = raise NotImplementedError
        def fail_events(_ids) = raise NotImplementedError
        def delete_events(_ids) = raise NotImplementedError
        def fetch_topics = raise NotImplementedError

        private

        attr_reader :outbox_table_name
      end
    end
  end
end
