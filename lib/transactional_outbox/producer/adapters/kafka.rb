# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Kafka < Interface
        def initialize(kafka)
          @producer = kafka.producer
        end

        def produce_batch(topic, events)
          buffer_events(topic, events)

          producer.deliver_messages
        end

        private

        def buffer_events(topic, events)
          events.each do |event|
            producer.produce(event.to_json, topic:)
          end
        end
      end
    end
  end
end
