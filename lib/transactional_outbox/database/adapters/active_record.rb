# frozen_string_literal: true


module TransactionalOutbox
  class Database
    class Adapters
      class ActiveRecord < Interface
        def dataset = abstract_model
        def transaction(*options, &) = abstract_model.transaction(*options, &)
        def select_for_update(dataset) = dataset.lock("FOR UPDATE SKIP LOCKED")

        private

        def abstract_model
          @abstract_model ||= Class.new(ActiveRecord::Base) { self.table_name = table } if defined?(ActiveRecord::Base)
        end
      end
    end
  end
end
