# frozen_string_literal: true

require_relative "workers_set"
require_relative "graceful_shutdown"

module TransactionalOutbox
  module Relay
    class Runner
      class << self
        def start
          workers_set = TransactionalOutbox::Relay::WorkersSet.new

          loop do
            topics = TransactionalOutbox::Repositories::OutboxEvent.new.fetch_topics

            topics.each do |topic|
              worker = workers_set.get_worker(topic)

              next if worker && worker.alive?
              next workers_set.replace_worker(topic) if worker.stop?

              workers_set.add_worker(topic)
            end

            sleep(1)
          end
        rescue SignalException => e
          puts "Received signal: #{e}. Shutting down..."

          TransactionalOutbox::Relay::GracefulShutdown.call(workers_set)
        end
      end
    end
  end
end
