# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class Interface
        def initialize(table)
          @table = table
        end

        def dataset = raise NotImplementedError
        def transaction(*_options, &) = raise NotImplementedError
        def select_for_update(_dataset) = raise NotImplementedError

        private

        attr_reader :table
      end
    end
  end
end
