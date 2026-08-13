# frozen_string_literal: true

require_relative "database/adapters/interface"
require_relative "database/adapters/active_record"
require_relative "database/adapters/sequel"

module TransactionalOutbox
  module Database
    extend Forwardable

    def_delegator :@adapter, :insert, :fetch_batch, :update_batch, :delete, :transaction

    def initialize(adapter = TransactionalOutbox.config.db.adapter)
      @adapter =
        case adapter.to_sym
        when :sequel then Adapters::Sequel
        else
          raise TransactionalOutbox::UnsupportedAdapter, "Unsupported adapter: #{adapter}"
        end
    end
  end
end
