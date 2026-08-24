# frozen_string_literal: true

module TransactionalOutbox
  class Relay
    class EventProcessor
      attr_reader :queue, :db, :producer

      def initialize(queue)
        @queue = queue
        @db = TransactionalOutbox::Database.new
        @producer = TransactionalOutbox::Producer.new
      end

      def call
        events = db.fetch_events(queue, config.relay.batch_size)

        return if events.empty?

        process_events(events)
      rescue StandardError => e
        TransactionalOutbox::Relay.monitor.publish(
          TransactionalOutbox::WORKER_EXCEPTIONS_TOTAL_MONITOR_EVENT,
          { queue:, exception: e.class.to_s }
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
        producer.produce_batch(queue, events)

        db.delete_events(events.map { |x| x[:id] })

        TransactionalOutbox::Relay.monitor.publish(
          TransactionalOutbox::WORKER_EVENTS_PROCESSED_MONITOR_EVENT, { queue:, count: events.size }
        )

        config.logger.info("Events have sent to queue #{queue}: #{events.size}")
      end
    end
  end
end
