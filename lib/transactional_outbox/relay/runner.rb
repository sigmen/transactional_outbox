# frozen_string_literal: true

require_relative "worker_set"
require_relative "worker_set/processor"
require_relative "graceful_shutdown"

module TransactionalOutbox
  class Relay
    class Runner
      class << self
        def start
          TransactionalOutbox::Relay.monitor.publish(TransactionalOutbox::RUNNER_INIT_MONITOR_EVENT)

          worker_set = TransactionalOutbox::Relay::WorkerSet.new

          start_relay(worker_set)
        rescue StandardError => e
          shutdown(e, worker_set, 1)
        rescue SignalException => e
          shutdown(e, worker_set, 0)
        end

        private

        def start_relay(worker_set) = TransactionalOutbox::Relay::WorkerSet::Processor.new(worker_set).call
        def config = @config ||= TransactionalOutbox.config

        def start_graceful_shutdown(worker_set, exit_code)
          return unless worker_set

          TransactionalOutbox::Relay::GracefulShutdown.call(worker_set, exit_code)
        end

        def shutdown(exception, worker_set, exit_code)
          config.logger&.info("Received exception: #{exception}. Shutting down...")

          start_graceful_shutdown(worker_set, exit_code)
        end
      end
    end
  end
end
