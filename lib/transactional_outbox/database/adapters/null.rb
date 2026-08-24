# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class Null < Interface
        class << self
          def dataset = @dataset ||= {}
          def clear_store = @dataset = {}
        end

        def transaction(*_options, &block) = block.call
        def insert_events(rows) = rows.each { |row| dataset[row[:id]] = row }

        def fetch_events(queue_name, batch_size)
          dataset.values.select { |row| row[:queue] == queue_name }.first(batch_size)
        end

        def fetch_queues = dataset.values.map { |row| row[:queue] }.uniq

        def move_to_processing(ids)
          ids.each { |id| dataset[id]&.merge!(status: TransactionalOutbox::EVENT_PROCESSING_STATUS) }
        end

        def delete_events(ids)
          ids.each { |id| dataset.delete(id) }

          true
        end

        private

        def dataset = self.class.dataset ||= {}
      end
    end
  end
end
