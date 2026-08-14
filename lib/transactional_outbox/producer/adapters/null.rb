# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Null < Interface
        class << self
          def messages = @messages ||= {}
        end

        def produce_batch(topic, batch)
          dataset = messages[topic] ||= []

          dataset.concat(messages)

          TransactionalOutbox.config.logger.info("Batch produced")
        end
      end
    end
  end
end
