# frozen_string_literal: true

module TransactionalOutbox
  module Relay
    class WorkersSet
      def initialize
        @workers = {}
      end

      def get_worker(topic) = workers[topic]

      def add_worker(topic)
        return if workers.key?(topic)

        workers[topic] = spawn_thread(topic)
      end

      def recover_worker(topic)
        return if get_worker(topic)&.alive?

        workers[topic] = spawn_thread(topic)
      end

      def stop_workers
        workers.each do |_, worker|
          next if worker.stop?

          worker[:shutdown] = true
        end
      end

      def all_stopped? = workers.all? { |_, worker| worker.stop? }

      private

      attr_reader :workers

      def spawn_thread(topic)
        thread = Thread.new do
          loop do
            messages = outbox_repository.fetch_batch(topic, config.batch_size)

            if messages.size > 0
              producer.produce_batch(messages)

              mutex.synchronize do
                outbox_repository.delete(messages.map { |x| x[:id] })
              end

              config.logger.info("Messages sent to topic #{topic}: #{messages.size}")
            end

            break config.logger.info("Thread for topic #{topic} successfully shutted down") if Thread.current[:shutdown]

            sleep(config.wait_between_batches_seconds)
          end
        end

        config.logger.info("Thread for topic #{topic} has been spawned")

        thread
      end

      def config = @config ||= TransactionalOutbox.config
      def outbox_repository = @outbox_repository ||= TransactionalOutbox::Repositories::OutboxEvent.new
      def producer = @producer ||= TransactionalOutbox::Producer.new
      def mutex = @mutext ||= Mutex.new
    end
  end
end
