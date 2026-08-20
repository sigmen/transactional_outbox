# frozen_string_literal: true

module TransactionalOutbox
  module Relay
    class FailBatch
      def initialize(events)
        @events = events
        @db = TransactionalOutbox::Database.new
      end

      def call
        ids = events.map { |event| event[:id] }

        db.fail_events(ids)
      end

      private

      attr_reader :events, :db
    end
  end
end
