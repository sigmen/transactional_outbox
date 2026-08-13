# frozen_string_literal: true

module TransactionalOutbox
  class Database
    module Adapters
      class Interface
        attr_reader :connection

        def initialize = @connection = TransactionalOutbox.config.db.connection

        def insert(_attributes) = raise NotImplemetedError
        def fetch_batch(_topic_name) = raise NotImplemetedError
        def update_batch(ids, attrs) = raise NotImplemetedError
        def delete(*ids) = raise NotImplemetedError
        def transaction(...) = raise NotImplemetedError
      end
    end
  end
end
