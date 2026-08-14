# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class Sequel < Interface
        def dataset(table) = db[table]
        def transaction(*options, &) = db.transaction(*options, &)
        def select_for_update(dataset) = dataset.for_update.skip_locked

        private

        def db = @db ||= Sequel::Model.db if defined?(Sequel)
      end
    end
  end
end
