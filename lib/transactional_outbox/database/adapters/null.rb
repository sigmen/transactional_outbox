# frozen_string_literal: true

module TransactionalOutbox
  class Database
    class Adapters
      class Null < Interface
        class << self
          def dataset = @dataset ||= []
          def clear_store = @dataset = []
        end

        def transaction(*_options, &block) = block.call

        def insert_events(rows)
          rows
            .map { |attrs| attrs.merge(id: SecureRandom.uuid) }
            .tap { |identified_rows| dataset.concat(identified_rows) }
        end

        def fetch_events(queue_name, batch_size) = dataset.select { |row| row[:queue] == queue_name }.first(batch_size)
        def fetch_queues = dataset.map { |row| row[:queue] }

        def delete_events(ids)
          ids_map = ids.to_h { |id| [id, true] }

          dataset.delete_if { |row| ids_map[row[:id]] }

          true
        end

        private

        def dataset = self.class.dataset ||= []
      end
    end
  end
end
