# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class ActiveRecord < Interface
        def transaction(*options, &) = model.transaction(*options, &)

        def fetch_events(queue, batch_size)
          model.where(queue:).order(:created_at).limit(batch_size).lock("FOR UPDATE SKIP LOCKED").map do |event|
            event.attributes.symbolize_keys
          end
        end

        def insert_events(attributes) = model.insert_all(attributes)
        def delete_events(ids) = model.where(id: ids).delete_all
        def fetch_queues = model.select(:queue).distinct.map(&:queue)

        def move_to_processing(ids)
          model.where(id: ids).update_all(status: TransactionalOutbox::EVENT_PROCESSING_STATUS)
        end

        private

        def model = @model ||= Object.const_get(config.db.connection_data[:model])
      end
    end
  end
end
