# frozen_string_literal: true

module TransactionalOutbox
  module Repositories
    class OutboxEvent
      class Null < Interface
        def initialize
          @dataset = []
        end

        def insert(attributes) = dataset << attributes.merge(id:)

        def update_batch(ids, attrs)
          ids_map = ids.to_h { |id| [id, true] }

          dataset.each do |row|
            next unless ids_map[row[:id]]

            row.merge!(attrs)
          end
        end

        def fetch_batch(topic_name, batch_size) = dataset.select { |row| row[:topic] == topic_name }.first(batch_size)
        def fetch_topics = dataset.map(&:topic)

        def delete(*ids)
          ids_map = ids.to_h { |id| [id, true] }

          dataset.delete_if { |row| ids_map[row[:id]] }
        end

        private

        attr_reader :dataset

        def id = SecureRandom.uuid
      end
    end
  end
end
