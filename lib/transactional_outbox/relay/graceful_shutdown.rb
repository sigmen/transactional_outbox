# frozen_string_literal: true

module TransactionalOutbox
  module Relay
    class GracefulShutdown
      class << self
        def call(worker_pool)
          shutdown_time = Time.now.utc

          worker_pool.stop_workers

          while shutdown_time + config.shutdown_waiting_time_seconds > Time.now.utc
            return config.logger.info("All workers have stopped.") if worker_pool.all_stopped?
          end
        end

        private

        def config = @config ||= TransactionalOutbox.config
      end
    end
  end
end
