# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Interface
        def initialize(connection_config)
          @connection_config = connection_config
        end

        def produce_batch(_queue, _batch) = raise NotImplementedError
        def close = raise NotImplementedError

        private

        attr_reader :connection_config
      end
    end
  end
end
