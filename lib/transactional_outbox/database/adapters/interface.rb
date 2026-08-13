# frozen_string_literal: true

module TransactionalOutbox
  class Database
    module Adapters
      class Interface
        def insert(_attributes) = raise NotImplemetedError
        def fetch_batch(_topic_name) = raise NotImplemetedError
        def update_batch(_ids, _attrs) = raise NotImplemetedError
        def delete(*_ids) = raise NotImplemetedError
        def transaction(*_options, &) = raise NotImplemetedError
      end
    end
  end
end
