# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Null < Interface
        def messages = @messages ||= {}
        def clear_store = @messages = {}

        def produce_batch(topic, events)
          msg = messages[topic] ||= []

          msg.concat(events)

          TransactionalOutbox.config.logger.info("Batch produced")
        end
      end
    end
  end
end
