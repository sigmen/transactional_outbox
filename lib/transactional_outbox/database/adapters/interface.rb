# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class Interface
        def initialize(table)
          @table = table
        end

        def dataset = raise NotImplemetedError
        def transaction(*_options, &) = raise NotImplemetedError
        def select_for_update(_dataset) = raise NotImplemetedError

        private

        attr_reader :table
      end
    end
  end
end
