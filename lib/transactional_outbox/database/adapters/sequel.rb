# frozen_string_literal: true

module TransactionalOutbox
  class Database
    module Adapters
      class Sequel
        def initialize(connection)
          @connection = connection
        end

        def dataset(table) = connection[table]
        def transaction(*options, &) = connection.transaction(*options, &)

        private

        attr_reader :connection
      end
    end
  end
end
