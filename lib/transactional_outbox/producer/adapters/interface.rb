# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Interface
        def initialize(producer)
          @producer = producer
        end

        def produce_batch(_topic, _batch) = raise NotImplementedError

        private

        attr_reader :producer
      end
    end
  end
end
