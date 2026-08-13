# frozen_string_literal: true

module TransactionalOutbox
  module Repositories
    class OutboxEvent
      class Interface
        def insert(_attributes) = raise NotImplemetedError
        def fetch_batch(_topic_name) = raise NotImplemetedError
        def fetch_topics = raise NotImplemetedError
        def update_batch(_ids, _attrs) = raise NotImplemetedError
        def delete(*_ids) = raise NotImplemetedError
      end
    end
  end
end
