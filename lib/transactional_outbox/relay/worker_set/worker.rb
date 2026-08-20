# frozen_string_literal: true

require_relative "../event_processor"

module TransactionalOutbox
  class Relay
    class WorkerSet
      class Worker
        attr_reader :topic, :db, :producer

        def initialize(topic)
          @topic = topic
        end

        def run
          @thread = spawn_thread
        end

        def shutdown
          return true if thread[:stopped]

          thread[:shutdown] = true
        end

        def shutting_down? = !thread.nil? && !!thread[:shutdown]
        def stopped? = !thread.nil? && !!thread[:stopped]

        private

        attr_reader :thread

        def config = @config ||= TransactionalOutbox.config

        def spawn_thread
          TransactionalOutbox::Relay.monitor.publish("worker.run", { topic: })

          Thread.new do
            loop do
              TransactionalOutbox::Relay::EventProcessor.new(topic).call

              if Thread.current[:shutdown]
                config.logger.info("Thread for topic #{topic} successfully shutted down")

                mark_thread_as_stopped

                break
              end

              break if config.test_environment

              sleep(config.wait_between_batches_seconds)
            end
          rescue StandardError => e
            mark_thread_as_stopped

            raise e
          end
        end

        def mark_thread_as_stopped
          Thread.current[:stopped] = true

          TransactionalOutbox::Relay.monitor.publish("worker.stopped", { topic: })
        end
      end
    end
  end
end
