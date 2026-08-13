# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    module Adapters
      class Karafka < Interface
        def produce_batch(batch) = producer.produce_many_sync(Oj.dump(batch))
      end
    end
  end
end
