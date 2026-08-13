# frozen_string_literal: true

require_relative "database/adapters/sequel"

module TransactionalOutbox
  class Database
    extend Forwardable

    def_delegators :@adapter_klass, :dataset, :transaction

    def initialize
      @adapter_klass = adapter_klass
    end

    private

    def adapter_klass
      adapter = TransactionalOutbox.config.db.adapter

      case adapter
      when :sequel then Adapters::Sequel
      else
        raise TransactionalOutbox::UnsupportedDatabaseAdapter, "Unsupported database adapter: #{adapter}"
      end
    end
  end
end
