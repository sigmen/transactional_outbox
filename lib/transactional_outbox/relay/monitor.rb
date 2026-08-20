# frozen_string_literal: true

module TransactionalOutbox
  class Relay
    class Monitor
      extend Forwardable

      def_delegators :@notifications, :publish, :subscribe

      def initialize
        @notifications = Dry::Monitor::Notifications.new(:transactional_outbox).tap { |n| register_events(n) }
      end

      private

      attr_reader :notifications

      def register_events(n)
        n.register_event(TransactionalOutbox::RUNNER_INIT_MONITOR_EVENT)
        n.register_event(TransactionalOutbox::RUNNER_STOPPED_MONITOR_EVENT)
        n.register_event(TransactionalOutbox::WORKER_RUN_MONITOR_EVENT)
        n.register_event(TransactionalOutbox::WORKER_EVENTS_PROCESSED_MONITOR_EVENT)
        n.register_event(TransactionalOutbox::WORKER_STOPPED_MONITOR_EVENT)
      end
    end
  end
end
