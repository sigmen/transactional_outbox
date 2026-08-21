# frozen_string_literal: true

module TransactionalOutbox
  class Database
    extend Forwardable

    def_delegators :@adapter, :transaction, :insert_events, :fetch_events, :fetch_topics, :delete_events

    def initialize
      @adapter = TransactionalOutbox::Database::Adapters.resolve(fetch_adapter).new
    end

    private

    def config = @config ||= TransactionalOutbox.config

    def fetch_adapter
      return :null if config.test_environment

      config.db.adapter.to_sym
    end
  end
end
