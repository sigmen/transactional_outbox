# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class Null < Base
        class << self
          def dataset = @dataset ||= {}
          def clear_store = @dataset = {}
        end

        def transaction(*_options, &block) = block.call

        def insert_events(rows)
          rows.each do |row|
            dataset[row[:id]] = row.merge(
              status: TransactionalOutbox::EVENT_NEW_STATUS, processing_started_at: current_time
            )
          end
        end

        def fetch_events(queue_name, batch_size)
          dataset.values.select { |row| row[:queue] == queue_name }.then { claimable_scope(_1) }.first(batch_size)
        end

        def fetch_queues = dataset.values.then { claimable_scope(_1) }.map { |row| row[:queue] }.uniq

        def move_to_processing(ids)
          ids.each { |id| dataset[id]&.merge!(status: TransactionalOutbox::EVENT_PROCESSING_STATUS) }
        end

        def delete_events(ids)
          ids.each { |id| dataset.delete(id) }

          true
        end

        private

        def dataset = self.class.dataset ||= {}

        def claimable_scope(scope)
          scope.select do |row|
            row[:status] == TransactionalOutbox::EVENT_NEW_STATUS || (
              row[:status] == TransactionalOutbox::EVENT_PROCESSING_STATUS &&
                row[:processing_started_at] < outdated_events_timestamp
            )
          end
        end
      end
    end
  end
end
