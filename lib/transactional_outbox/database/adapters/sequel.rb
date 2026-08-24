# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class Sequel < Interface
        def transaction(*options, &) = db.transaction(*options, &)
        def insert_events(attributes) = table_object.multi_insert(attributes)
        def fetch_queues = table_object.select(:queue).distinct.map { |event| event[:queue] }
        def delete_events(ids) = table_object.where(id: ids).delete

        def move_to_processing(ids)
          table_object.where(id: ids).update(status: TransactionalOutbox::EVENT_PROCESSING_STATUS)
        end

        def fetch_events(queue, batch_size)
          dataset = table_object.where(queue:).order(:created_at).limit(batch_size)
          dataset = dataset.for_update.skip_locked unless config.test_environment

          dataset.all
        end

        private

        def db = @db ||= config.db.connection_data[:db]
        def table_object = @table_object ||= db.from(outbox_table_name)
      end
    end
  end
end
