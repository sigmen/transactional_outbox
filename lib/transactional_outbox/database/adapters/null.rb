# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class Null < Interface
        class << self
          def dataset = @dataset ||= {}
          def clear
            @dataset[table] = value
          end
        end

        def dataset = self.class.dataset[table] ||= []
        def transaction(*_options, &block) = block.call
        def select_for_update(ds) = ds
      end
    end
  end
end
