# frozen_string_literal: true

module TransactionalOutbox
  class Database
    extend Forwardable

    def_delegators :@adapter_klass, :dataset, :transaction

    def initialize
      @adapter_klass = Adapters.resolve(TransactionalOutbox.config.db.adapter.to_sym)
    end
  end
end
