# frozen_string_literal: true

module TransactionalOutbox
  module Repositories
    class OutboxEvent
      class Interface
        def insert(_attributes) = raise NotImplementedError
        def fetch_batch(_topic_name) = raise NotImplementedError
        def fetch_topics = raise NotImplementedError
        def update_batch(_ids, _attrs) = raise NotImplementedError
        def delete(_ids) = raise NotImplementedError
      end
    end
  end
end
