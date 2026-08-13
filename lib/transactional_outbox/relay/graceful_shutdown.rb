# frozen_string_literal: true

module TransactionalOutbox
  module Relay
    class GracefulShutdown
      class << self
        def call(workers_set)
          shutdown_time = Time.now.utc

          workers_set.stop_workers

          while shutdown_time + config.shutdown_waiting_time_seconds > Time.now.utc
            return config.logger.info("All workers have stopped.") if workers_set.all_stopped?
          end
        end

        private

        def config = @config ||= TransactionalOutbox.config
      end
    end
  end
end
