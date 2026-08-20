# frozen_string_literal: true

module TransactionalOutbox
  class Database
    extend Forwardable

    def_delegators :@adapter, :dataset, :transaction

    def initialize
      @adapter = TransactionalOutbox::Adapters::Database.resolve(fetch_adapter).new(config.outbox_table_name)
    end

    private

    def config = @config ||= TransactionalOutbox.config

    def fetch_adapter
      return :null if config.test_environment

      config.db.adapter.to_sym
    end
  end
end
