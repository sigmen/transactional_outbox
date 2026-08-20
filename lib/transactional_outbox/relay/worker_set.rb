# frozen_string_literal: true

require_relative "worker_set/worker"

module TransactionalOutbox
  class Relay
    class WorkerSet
      def initialize
        @workers = {}
      end

      def get_worker(topic) = workers[topic]

      def add_worker(topic)
        return if workers.key?(topic)

        set_worker(topic)
      end

      def try_to_recover_worker(topic)
        worker = get_worker(topic)

        return if !worker.nil? && (worker.shutting_down? || !worker.stopped?)

        set_worker(topic)
      end

      def stop_workers = workers.values.each(&:shutdown)
      def all_stopped? = workers.values.all?(&:stopped?)

      private

      attr_reader :workers

      def set_worker(topic) = workers[topic] = Worker.new(topic).tap(&:run)
    end
  end
end
