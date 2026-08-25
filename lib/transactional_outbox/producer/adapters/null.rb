# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Null < Base
        def messages = @messages ||= {}
        def clear_store = @messages = {}

        def produce_batch(queue, events)
          msg = messages[queue] ||= []

          msg.concat(events)

          TransactionalOutbox.config.logger&.info("Batch produced")
        end

        def close = true
      end
    end
  end
end
