# frozen_string_literal: true

require_relative "workers_set"
require_relative "graceful_shutdown"

module TransactionalOutbox
  module Relay
    class Runner
      class << self
        def start
          @workers_set = TransactionalOutbox::Relay::WorkersSet.new
          @retry_counter = 0

          process_relay
        rescue StandardError => e
          config.logger.info("Received exception: #{e}. Shutting down...")

          start_graceful_shutdown

          exit(1)
        rescue SignalException => e
          config.logger.info("Received system signal: #{e}. Shutting down...")

          start_graceful_shutdown

          exit(0)
        end

        private

        attr_reader :workers_set

        def process_relay
          loop do
            topics = db.fetch_topics

            topics.each do |topic|
              worker = workers_set.get_worker(topic)

              worker ? workers_set.try_to_recover_worker(topic) : workers_set.add_worker(topic)
            end

            sleep(1)

            @retry_counter = 0
          rescue StandardError => e
            config.logger.error("Exception: #{e}, trying to retry...")

            @retry_counter += 1

            raise e if @retry_counter > config.max_relay_runner_retries_count

            sleep(calculate_retry_delay)

            retry
          end
        end

        def db = @db ||= TransactionalOutbox::Database.new
        def config = @config ||= TransactionalOutbox.config
        def calculate_retry_delay = TransactionalOutbox::ExponentialBackoff.calculate_retry_delay(@retry_counter)

        def start_graceful_shutdown
          return unless workers_set

          TransactionalOutbox::Relay::GracefulShutdown.call(workers_set)
        end
      end
    end
  end
end
