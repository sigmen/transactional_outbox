# frozen_string_literal: true

module TransactionalOutbox
  class Relay
    class GracefulShutdown
      class << self
        def call(worker_set)
          shutdown_time = Time.now.utc

          worker_set.stop_workers

          while shutdown_time + config.shutdown_waiting_time_seconds > Time.now.utc
            if worker_set.all_stopped?
              TransactionalOutbox::Relay.monitor.publish("runner.stopped")

              config.logger.info("All workers have stopped.")

              return true
            end

            sleep(0.1)
          end

          false
        end

        private

        def config = @config ||= TransactionalOutbox.config
      end
    end
  end
end
