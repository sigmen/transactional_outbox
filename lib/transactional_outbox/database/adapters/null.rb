# frozen_string_literal: true

module TransactionalOutbox
  class Database
    module Adapters
      class Null < Interface
        def initialize
          @db = []
        end

        def insert(attributes) = db << attributes.merge(id:)

        def update_batch(ids, attrs)
          ids_map = ids.to_h { |id| [id, true] }

          db.each do |row|
            next unless ids_map[row[:id]]

            row.merge!(attrs)
          end
        end

        def fetch_batch(topic_name, batch_size) = db.select { |row| row[:topic] == topic_name }.first(batch_size)
        def fetch_topics = db.map(&:topic)

        def delete(*ids)
          ids_map = ids.to_h { |id| [id, true] }

          db.delete_if { |row| ids_map[row[:id]] }
        end

        def transaction(*_options, &block) = block.call

        private

        attr_reader :db

        def id = SecureRandom.uuid
      end
    end
  end
end
