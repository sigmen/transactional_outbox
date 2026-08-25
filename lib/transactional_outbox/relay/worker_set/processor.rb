# frozen_string_literal: true

module TransactionalOutbox
  class Relay
    class WorkerSet
      class Processor
        def initialize(worker_set)
          @worker_set = worker_set
          @db = TransactionalOutbox::Database.new
        end

        def call # rubocop:disable Metrics/MethodLength
          @retry_counter = 0

          loop do
            queues = db.fetch_queues

            process_queues(queues)

            break if config.test_environment

            @retry_counter = 0
          rescue StandardError => e
            config.logger&.error("Exception: #{e}, trying to retry...")

            raise e if @retry_counter >= config.relay.max_runner_retries_count

            @retry_counter += 1

            sleep(calculate_retry_delay)

            retry
          end
        end

        private

        attr_reader :worker_set, :db

        def config = @config ||= TransactionalOutbox.config
        def calculate_retry_delay = TransactionalOutbox::ExponentialBackoff.calculate_retry_delay(@retry_counter)

        def process_queues(queues)
          queues.each do |queue|
            worker = worker_set.get_worker(queue)

            worker ? worker_set.try_to_recover_worker(queue) : worker_set.add_worker(queue)
          end

          sleep(config.relay.delay_between_worker_set_processor_cycles_seconds)
        end
      end
    end
  end
end
