# frozen_string_literal: true

module TransactionalOutbox
  class Relay
    class WorkerSet
      class Processor
        def initialize(worker_set)
          @worker_set = worker_set
          @db = TransactionalOutbox::Database.new
        end

        def call
          @retry_counter = 0

          loop do
            topics = db.fetch_topics

            process_topics(topics)

            @retry_counter = 0
          rescue StandardError => e
            config.logger.error("Exception: #{e}, trying to retry...")

            @retry_counter += 1

            raise e if @retry_counter > config.max_relay_runner_retries_count

            sleep(calculate_retry_delay)

            retry
          end
        end

        private

        attr_reader :worker_set, :db

        def config = @config ||= TransactionalOutbox.config
        def calculate_retry_delay = TransactionalOutbox::ExponentialBackoff.calculate_retry_delay(@retry_counter)

        def process_topics(topics)
          topics.each do |topic|
            worker = worker_set.get_worker(topic)

            worker ? worker_set.try_to_recover_worker(topic) : worker_set.add_worker(topic)
          end

          sleep(1)
        end
      end
    end
  end
end
