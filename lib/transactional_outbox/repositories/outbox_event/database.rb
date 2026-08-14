# frozen_string_literal: true

module TransactionalOutbox
  module Repositories
    class OutboxEvent
      class Database < Interface
        def insert(attributes) = outbox_table.insert(attributes)

        def fetch_batch(topic_name, batch_size)
          outbox_table.where(topic_name:).limit(batch_size).order(:created_at)
            .then { database.select_for_update(_1) }
            .then(&:all)
        end

        def update_batch(ids, attrs) = outbox_table.where(id: ids).update(attrs)
        def fetch_topics = outbox_table.select(:topic).distinct.map(&:topic)
        def delete(*ids) = outbox_table.where(id: ids).delete

        private

        def database = @database ||= TransactionalOutbox::Database.new
        def outbox_table = database.dataset(TransactionalOutbox.config.outbox_table_name)
      end
    end
  end
end
