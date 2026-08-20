# frozen_string_literal: true

module TransactionalOutbox
  module Relay
    class EventProcessor
      def initialize(topic)
        @topic = topic
        @db = TransactionalOutbox::Database.new
        @producer = TransactionalOutbox::Producer.new
      end

      def call
        events = db.fetch_events(topic, config.batch_size)

        return unless events.size > 0

        producer.produce_batch(topic, events)

        db.delete_events(events.map { |x| x[:id] })

        config.logger.info("Events have sent to topic #{topic}: #{events.size}")
      rescue StandardError => e
        config.relay.failover.call(e, self)
      end

      private

      attr_reader :topic, :db, :producer

      def config = @config ||= TransactionalOutbox.config
    end
  end
end
