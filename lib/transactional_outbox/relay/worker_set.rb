# frozen_string_literal: true

require_relative "worker_set/worker"

module TransactionalOutbox
  class Relay
    class WorkerSet
      def initialize
        @workers = {}
      end

      def get_worker(queue) = workers[queue]

      def add_worker(queue)
        return if workers.key?(queue)

        create_worker(queue)
      end

      def try_to_recover_worker(queue)
        worker = get_worker(queue)

        return if !worker.nil? && (worker.shutting_down? || !worker.stopped?)

        create_worker(queue)
      end

      def stop_workers = workers.each_value(&:shutdown)
      def all_stopped? = workers.values.all?(&:stopped?)

      private

      attr_reader :workers

      def create_worker(queue) = workers[queue] = Worker.new(queue).tap(&:run)
    end
  end
end
