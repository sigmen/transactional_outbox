# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    module Adapters
      class Null < Interface
        def produce_batch(_batch) = TransactionalOutbox.config.logger.info("Batch produced")
      end
    end
  end
end
