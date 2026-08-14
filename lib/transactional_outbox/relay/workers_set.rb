# frozen_string_literal: true

require_relative "workers_set/worker"

module TransactionalOutbox
  module Relay
    class WorkersSet
      def initialize
        @workers_set = {}
      end

      def get_worker(topic) = workers_set[topic]

      def add_worker(topic)
        return if workers_set.key?(topic)

        set_worker(topic)
      end

      def try_to_recover_worker(topic)
        worker = get_worker(topic)

        return if worker.shutting_down? || !worker.stopped?

        set_worker(topic)
      end

      def stop_workers = workers.each(&:shutdown)
      def all_stopped? = workers.all?(&:stopped?)

      private

      attr_reader :workers_set

      def workers = workers_set.values
      def set_worker(topic) = workers_set[topic] = Worker.new(topic)
    end
  end
end
