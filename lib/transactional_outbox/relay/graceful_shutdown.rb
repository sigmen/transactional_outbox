# frozen_string_literal: true

module TransactionalOutbox
  class Relay
    class GracefulShutdown
      class << self
        def call(worker_set, exit_code = 0)
          worker_set.stop_workers

          call_exit(exit_code) if wait_workers(worker_set)
        end

        private

        def config = @config ||= TransactionalOutbox.config

        def wait_workers(worker_set)
          shutdown_time = Time.now.utc

          while shutdown_time + config.shutdown_waiting_time_seconds > Time.now.utc
            if worker_set.all_stopped?
              TransactionalOutbox::Relay.monitor.publish(TransactionalOutbox::RUNNER_STOPPED_MONITOR_EVENT)

              config.logger&.info("All workers have stopped.")

              return true
            end

            sleep(0.1)
          end

          false
        end

        def call_exit(code)
          return code if config.test_environment

          exit(code)
        end
      end
    end
  end
end
