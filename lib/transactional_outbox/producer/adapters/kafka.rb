# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Kafka < Base
        def produce_batch(topic, events)
          buffer_events(topic, events)

          producer.deliver_messages
        end

        def close = client.close

        private

        def client = @client ||= ::Kafka.new(**connection_config)
        def producer = @producer ||= client.producer

        def buffer_events(topic, events)
          events.each do |event|
            producer.produce(event.to_json, topic:)
          end
        end
      end
    end
  end
end
