# frozen_string_literal: true

module TransactionalOutbox
  module Adapters
    class Database
      class Sequel < Interface
        def transaction(*options, &) = dataset.transaction(*options, &)
        def insert_events(attributes) = dataset.insert(attributes)
        def fetch_topics = dataset.select(:topic).distinct.map(&:topic)
        def delete_events(ids) = dataset.where(id: ids).delete

        def fetch_events(topic_name, batch_size)
          dataset
            .where(topic_name:)
            .where(Sequel.lit("next_retry_at IS NULL OR next_retry_at < current_timestamp"))
            .order(:created_at)
            .limit(batch_size)
            .for_update.skip_locked
            .all
        end

        private

        def dataset
          @dataset ||= if config.db.adapter == :sequel && defined?(Sequel)
            Sequel::Model.db[outbox_table_name]
          end
        end
      end
    end
  end
end
