# frozen_string_literal: true

require_relative "associated_worker_pool"

module TransactionalOutbox
  module Relay
    class Processor
      class << self
        def start
          pool = TransactionalOutbox::Relay::AssociatedWorkerPool.new

          loop do
            topics = TransactionalOutbox::Database.new.fetch_topics

            topics.each do |topic|
              worker = pool.get_worker(topic)

              next if worker && worker.alive?
              next pool.replace_worker(topic) if worker.stop?

              pool.add_worker(topic)
            end

            sleep(1)
          end
        rescue SignalException => e
          puts "Received Signal #{e}. Shutting down..."

          TransactionalOutbox::Relay::GracefulShutdown.call(pool)
        end
      end
    end
  end
end
