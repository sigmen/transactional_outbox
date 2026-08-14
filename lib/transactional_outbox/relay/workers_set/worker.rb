# frozen_string_literal: true

module TransactionalOutbox
  module Relay
    class WorkersSet
      class Worker
        def initialize(topic)
          @topic = topic
          @thread = spawn_thread(topic)
        end

        def shutdown
          return true if thread[:stopped]

          thread[:shutdown] = true
        end

        def shutting_down? = thread[:shutdown]
        def stopped? = thread[:stopped]

        private

        attr_reader :thread

        def config = @config ||= TransactionalOutbox.config
        def outbox_repository = @outbox_repository ||= TransactionalOutbox::Repositories::OutboxEvent.new
        def producer = @producer ||= TransactionalOutbox::Producer.new

        def spawn_thread(topic)
          thread = Thread.new do
            loop do
              messages = outbox_repository.fetch_batch(topic, config.batch_size)

              if messages.size > 0
                producer.produce_batch(messages)

                outbox_repository.delete(messages.map { |x| x[:id] })

                config.logger.info("Messages sent to topic #{topic}: #{messages.size}")
              end

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

        def mark_as_stopped = thread[:stopped] = true
      end
    end
  end
end
