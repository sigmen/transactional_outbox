# frozen_string_literal: true

module TransactionalOutbox
  module Adapters
    class Database
      class Sequel < Interface
        def dataset(table) = db[table]
        def transaction(*options, &) = db.transaction(*options, &)
        def select_for_update(dataset) = dataset.for_update.skip_locked

        private

        def config = @config ||= TransactionalOutbox.config
        def db = @db ||= get_db_object

        def get_db_object
          return unless config.db.adapter == :sequel && defined?(Sequel)

          Sequel::Model.db
        end
      end
    end
  end
end
