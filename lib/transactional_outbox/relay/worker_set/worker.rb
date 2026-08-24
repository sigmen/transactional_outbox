# frozen_string_literal: true

require_relative "../event_processor"

module TransactionalOutbox
  class Relay
    class WorkerSet
      class Worker
        attr_reader :queue, :db, :producer

        def initialize(queue)
          @queue = queue
          @producer = TransactionalOutbox::Producer.new
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

        def spawn_thread # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          TransactionalOutbox::Relay.monitor.publish(TransactionalOutbox::WORKER_RUN_MONITOR_EVENT, { queue: })

          Thread.new do
            loop do
              TransactionalOutbox::Relay::EventProcessor.new(queue, producer).call

              if Thread.current[:shutdown]
                config.logger.info("Thread for queue #{queue} successfully shutted down")

                mark_thread_as_stopped

                break
              end

              break mark_thread_as_stopped if config.test_environment

              sleep(config.relay.wait_between_batches_seconds)
            end
          rescue StandardError => e
            mark_thread_as_stopped

            raise e
          ensure
            producer&.close
          end
        end

        def mark_thread_as_stopped
          Thread.current[:stopped] = true

          TransactionalOutbox::Relay.monitor.publish(TransactionalOutbox::WORKER_STOPPED_MONITOR_EVENT, { queue: })
        end
      end
    end
  end
end
