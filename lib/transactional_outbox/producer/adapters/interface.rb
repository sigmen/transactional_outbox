# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Interface
        def produce_batch(_queue, _batch) = raise NotImplementedError
        def close = raise NotImplementedError
      end
    end
  end
end
