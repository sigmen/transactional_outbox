# frozen_string_literal: true

module TransactionalOutbox
  class Database
    module Adapters
      class Sequel < Interface
        def insert(attributes) = connection.insert(attributes)
        def fetch_batch(topic_name) = connection.where(topic_name:).all
        def update_batch(ids, attrs) = connection.where(id: ids).update(attrs)
        def delete(*ids) = connection.where(id: ids).delete
        def transaction(...) = connection.transaction(...) { yield }
      end
    end
  end
end
