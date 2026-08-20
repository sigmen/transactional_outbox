# frozen_string_literal: true

module TransactionalOutbox
  module Adapters
    class Database
      class ActiveRecord < Interface
        def transaction(*options, &) = abstract_model.transaction(*options, &)

        def fetch_events(topic_name, batch_size)
          abstract_model
            .where(topic_name:)
            .where("next_retry_at IS NULL OR next_retry_at < current_timestamp")
            .order(:created_at)
            .limit(batch_size)
            .lock("FOR UPDATE SKIP LOCKED")
            .all
        end

        def insert_events(attributes) = abstract_model.insert_all(attributes)
        def delete_events(ids) = abstract_model.where(id: ids).delete
        def fetch_topics = abstract_model.select(:topic).distinct.map(&:topic)

        private

        def abstract_model
          @abstract_model ||= if config.db.adapter == :active_record && defined?(ActiveRecord::Base)
            Class.new(ActiveRecord::Base) { self.table_name = outbox_table_name }
          end
        end
      end
    end
  end
end
