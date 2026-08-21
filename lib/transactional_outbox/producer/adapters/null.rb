# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Null < Interface
        class << self
          def messages = @messages ||= {}
          def clear_store = @messages = {}
        end

        def produce_batch(topic, events)
          messages = self.class.messages[topic] ||= []

          messages.concat(events)

          TransactionalOutbox.config.logger.info("Batch produced")
        end
      end
    end
  end
end
