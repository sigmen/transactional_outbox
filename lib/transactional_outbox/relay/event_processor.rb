# frozen_string_literal: true

module TransactionalOutbox
  class Relay
    class EventProcessor
      attr_reader :queue, :db, :producer

      def initialize(queue, producer)
        @queue = queue
        @db = TransactionalOutbox::Database.new
        @producer = producer
      end

      def call
        process
      rescue StandardError => e
        TransactionalOutbox::Relay.monitor.publish(
          TransactionalOutbox::WORKER_EXCEPTIONS_TOTAL_MONITOR_EVENT,
          { queue:, exception: e.class.to_s }
        )

        resolve_failover.call(e, @events)
      end

      private

      def config = @config ||= TransactionalOutbox.config

      def resolve_failover
        configured = config.relay.failover

        return Object.const_get(configured) if configured.is_a?(String)

        configured
      end

      def process # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        db.transaction do
          @events = db.fetch_events(queue, config.relay.batch_size)

          db.move_to_processing(events_ids) unless @events.empty?
        end

        return if @events.empty?

        producer.produce_batch(queue, @events)

        db.delete_events(events_ids)

        events_count = @events.size

        TransactionalOutbox::Relay.monitor.publish(
          TransactionalOutbox::WORKER_EVENTS_PROCESSED_MONITOR_EVENT, { queue:, count: events_count }
        )

        config.logger&.info("Events have sent to queue #{queue}: #{events_count}")
      end

      def events_ids = @events_ids ||= @events.map { |e| e[:id] }
    end
  end
end
