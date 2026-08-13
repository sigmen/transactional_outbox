# frozen_string_literal: true

module TransactionalOutbox
  module Relay
    class AssociatedWorkerPool
      def initialize
        @pool = {}
      end

      def get_worker(topic) = pool[topic]

      def add_worker(topic)
        mutex.syncronize do
          return if pool.key?(topic)

          pool[topic] = spawn_thread(topic)
        end
      end

      def recover_worker(topic)
        mutex.syncronize do
          return if get_worker(topic)&.alive?

          pool[topic] = spawn_thread(topic)
        end
      end

      def stop_workers
        pool.each do |_, worker|
          next if worker.stop?

          worker[:shutdown] = true
        end
      end

      def all_stopped? = pool.all? { |_, worker| worker.stop? }

      private

      attr_reader :pool

      def spawn_thread(topic)
        thread = Thread.new do
          loop do
            messages = db.fetch_batch(topic, config.batch_size)

            if messages.size > 0
              producer.produce_batch(messages)

              db.delete(messages.map(&:id))

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
      def db = @db ||= TransactionalOutbox::Database.new
      def producer = @producer ||= TransactionalOutbox::Producer.new
      def mutex = @mutex ||= Mutex.new
    end
  end
end
