# frozen_string_literal: true

module TransactionalOutbox
  module Adapters
    class Database
      class Null < Interface
        class << self
          def dataset = @__dataset__ ||= []
          def clear_store = @__dataset__ = []
        end

        def transaction(*_options, &block) = block.call

        def insert_events(rows)
          rows
            .map { |attrs| attrs.merge(id: SecureRandom.uuid) }
            .tap { |identified_rows| dataset.concat(identified_rows) }
        end

        def fail_events(ids)
          ids_map = ids.to_h { |id| [id, true] }

          dataset.each do |row|
            next unless ids_map[row[:id]]

            row.merge!(attrs)
          end
        end

        def fetch_events(topic_name, batch_size) = dataset.select { |row| row[:topic] == topic_name }.first(batch_size)
        def fetch_topics = dataset.map { |row| row[:topic] }

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
