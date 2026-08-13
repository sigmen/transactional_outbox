# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    module Adapters
      class Interface
        def initialize(producer)
          @producer = producer
        end

        def produce_batch(_batch) = raise NotImplemetedError

        private

        attr_reader :producer
      end
    end
  end
end
