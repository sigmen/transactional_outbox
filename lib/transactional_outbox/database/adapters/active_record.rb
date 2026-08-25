# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class ActiveRecord < Base
        def transaction(*options, &) = model.transaction(*options, &)

        def fetch_events(queue, batch_size)
          claimable_scope(model.where(queue:))
            .order(:created_at)
            .limit(batch_size)
            .lock("FOR UPDATE SKIP LOCKED")
            .map { |event| event.attributes.symbolize_keys }
        end

        def insert_events(attributes) = model.insert_all(attributes)
        def delete_events(ids) = model.where(id: ids).delete_all
        def fetch_queues = claimable_scope(model).select(:queue).distinct.map(&:queue)

        def move_to_processing(ids)
          model
            .where(id: ids)
            .update_all(status: TransactionalOutbox::EVENT_PROCESSING_STATUS, processing_started_at: current_time)
        end

        private

        def model = @model ||= Object.const_get(config.db.connection_data[:model])

        def claimable_scope(scope)
          scope
            .where(status: TransactionalOutbox::EVENT_NEW_STATUS)
            .or(
              scope
                .where(status: TransactionalOutbox::EVENT_PROCESSING_STATUS)
                .where(processing_started_at: ...outdated_events_timestamp)
            )
        end
      end
    end
  end
end
