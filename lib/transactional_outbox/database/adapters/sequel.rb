# frozen_string_literal: true

module TransactionalOutbox
  class Database
    module Adapters
      class Sequel < Interface
        def insert(attributes) = connection.insert(attributes)

        def fetch_batch(topic_name, batch_size)
          connection.where(topic_name:).for_update.skip_locked.limit(batch_size).order(:created_at).all
        end

        def update_batch(ids, attrs) = connection.where(id: ids).update(attrs)
        def fetch_topics = connection.select(:topic).distinct.map(&:topic)
        def delete(*ids) = connection.where(id: ids).delete
        def transaction(*options, &) = connection.transaction(*options, &)

        private

        def config = @config ||= TransactionalOutbox.config
        def connection = config.db.connection[config.outbox_table_name]
      end
    end
  end
end
