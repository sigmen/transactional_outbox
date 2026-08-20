# frozen_string_literal: true

module TransactionalOutbox
  module Relay
    class WorkersSet
      class Worker
        def initialize(topic)
          @topic = topic
          @db = TransactionalOutbox::Database.new
          @producer = TransactionalOutbox::Producer.new
        end

        def run
          @thread = spawn_thread
        end

        def shutdown
          return true if thread[:stopped]

          thread[:shutdown] = true
        end

        def shutting_down? = thread[:shutdown]
        def stopped? = thread[:stopped]

        private

        attr_reader :topic, :db, :producer, :thread

        def config = @config ||= TransactionalOutbox.config

        def spawn_thread
          thread = Thread.new do
            loop do
              process_batch

              if Thread.current[:shutdown]
                config.logger.info("Thread for topic #{topic} successfully shutted down")

                mark_as_stopped

                break
              end

              sleep(config.wait_between_batches_seconds)
            end
          rescue StandardError => e
            mark_as_stopped

            raise e
          end
        end

        def process_batch
          events = db.fetch_events(topic, config.batch_size)

          return unless events.size > 0

          producer.produce_batch(topic, events)

          db.delete_events(events.map { |x| x[:id] })

          config.logger.info("Events have sent to topic #{topic}: #{events.size}")
        end

        def mark_as_stopped = thread[:stopped] = true
      end
    end
  end
end
