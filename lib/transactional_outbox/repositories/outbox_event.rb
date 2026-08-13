# frozen_string_literal: true

require_relative "outbox_event/interface"
require_relative "outbox_event/null"
require_relative "outbox_event/database"

module TransactionalOutbox
  module Repositories
    class OutboxEvent
      extend Forwardable

      def_delegators :@repository_instance, :insert, :fetch_batch, :fetch_topics, :update_batch, :delete

      def initialize
        @repository_instance = get_repository_klass.new
      end

      private

      def get_repository_klass(adapter) = TransactionalOutbox.config.test_environment ? Null : Database
    end
  end
end
