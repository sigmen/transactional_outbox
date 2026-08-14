# frozen_string_literal: true


module TransactionalOutbox
  class Database
    class Adapters
      class ActiveRecord < Interface
        def dataset = abstract_model
        def transaction(*options, &) = abstract_model.transaction(*options, &)
        def select_for_update(dataset) = dataset.lock("FOR UPDATE SKIP LOCKED")

        private

        def config = @config ||= TransactionalOutbox.config
        def abstract_model = @abstract_model ||= build_abstract_model

        def build_abstract_model
          return unless config.db.adapter == :active_record && defined?(ActiveRecord::Base)

          Class.new(ActiveRecord::Base) { self.table_name = table }
        end
      end
    end
  end
end
