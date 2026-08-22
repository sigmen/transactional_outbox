# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Interface
        def initialize(client)
          @client = client
        end

        def produce_batch(_topic, _batch) = raise NotImplementedError

        private

        attr_reader :client
      end
    end
  end
end
