# frozen_string_literal: true

require_relative "database/adapters/sequel"

module TransactionalOutbox
  class Database
    extend Forwardable

    def_delegators :@adapter_klass, :dataset, :transaction

    def initialize
      @adapter_klass = TransactionalOutbox.config.db.adapter
    end
  end
end
