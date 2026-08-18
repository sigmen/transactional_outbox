# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class Karafka < Interface
        def produce_batch(topic, batch) = producer.produce_many_sync(prepare_messages(topic, batch))

        private

        def prepare_messages(topic, batch) = batch.map { |message| { topic:, payload: message.to_json } }
      end
    end
  end
end
