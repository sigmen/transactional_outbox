# frozen_string_literal: true

module TransactionalOutbox
  module Adapters
    class Producer
      class Karafka < Interface
        def produce_batch(topic, events) = producer.produce_many_sync(prepare_events(topic, events))

        private

        def prepare_events(topic, events) = events.map { |event| { topic:, payload: event.to_json } }
      end
    end
  end
end
