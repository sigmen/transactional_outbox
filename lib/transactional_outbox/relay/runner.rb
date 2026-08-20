# frozen_string_literal: true

require_relative "worker_set"
require_relative "worker_set/processor"
require_relative "graceful_shutdown"

module TransactionalOutbox
  class Relay
    class Runner
      class << self
        def start
          TransactionalOutbox::Relay.monitor.publish("runner.init")

          worker_set = TransactionalOutbox::Relay::WorkerSet.new

          start_relay(worker_set)
        rescue StandardError => e
          config.logger.info("Received exception: #{e}. Shutting down...")

          start_graceful_shutdown(worker_set)

          exit(1)
        rescue SignalException => e
          config.logger.info("Received system signal: #{e}. Shutting down...")

          start_graceful_shutdown(worker_set)

          exit(0)
        end

        private

        def start_relay(worker_set) = TransactionalOutbox::Relay::WorkerSet::Processor.new(worker_set).call
        def config = @config ||= TransactionalOutbox.config

        def start_graceful_shutdown(worker_set)
          return unless worker_set

          TransactionalOutbox::Relay::GracefulShutdown.call(worker_set)
        end
      end
    end
  end
end
