# frozen_string_literal: true

require_relative "associated_worker_pool"
require_relative "graceful_shutdown"

module TransactionalOutbox
  module Relay
    class Runner
      class << self
        def start
          worker_pool = TransactionalOutbox::Relay::AssociatedWorkerPool.new

          loop do
            topics = TransactionalOutbox::Repositories::OutboxEvent.new.fetch_topics

            topics.each do |topic|
              worker = worker_pool.get_worker(topic)

              next if worker && worker.alive?
              next worker_pool.replace_worker(topic) if worker.stop?

              worker_pool.add_worker(topic)
            end

            sleep(1)
          end
        rescue SignalException => e
          puts "Received signal: #{e}. Shutting down..."

          TransactionalOutbox::Relay::GracefulShutdown.call(worker_pool)
        end
      end
    end
  end
end
