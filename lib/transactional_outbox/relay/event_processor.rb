# frozen_string_literal: true

module TransactionalOutbox
  class Relay
    class EventProcessor
      attr_reader :topic, :db, :producer

      def initialize(topic)
        @topic = topic
        @db = TransactionalOutbox::Database.new
        @producer = TransactionalOutbox::Producer.new
      end

      def call
        events = db.fetch_events(topic, config.relay.batch_size)

        return if events.empty?

        process_events(events)
      rescue StandardError => e
        TransactionalOutbox.monitor.publish(
          TransactionalOutbox::WORKER_EXCEPTIONS_TOTAL_MONITOR_EVENT,
          { topic:, exception: e.class }
        )

        resolve_failover.call(e, events)
      end

      private

      def config = @config ||= TransactionalOutbox.config

      def resolve_failover
        configured = config.relay.failover

        return Object.get_const(configured) if configured.is_a?(String)

        configured
      end

      def process_events(events)
        producer.produce_batch(topic, events)

        db.delete_events(events.map { |x| x[:id] })

        TransactionalOutbox::Relay.monitor.publish(
          TransactionalOutbox::WORKER_EVENTS_PROCESSED_MONITOR_EVENT, { topic:, count: events.size }
        )

        config.logger.info("Events have sent to topic #{topic}: #{events.size}")
      end
    end
  end
end
