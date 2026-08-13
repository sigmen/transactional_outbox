# frozen_string_literal: true

require_relative "database/adapters/interface"
require_relative "database/adapters/null"
require_relative "database/adapters/sequel"

module TransactionalOutbox
  class Database
    extend Forwardable

    def_delegators :@adapter, :insert, :fetch_batch, :fetch_topics, :update_batch, :delete, :transaction

    def initialize(adapter = TransactionalOutbox.config.db.adapter)
      @adapter = get_adapter_klass(adapter).new
    end

    private

    def get_adapter_klass(adapter)
      case adapter.to_sym
      when :null then Adapters::Null
      when :sequel then Adapters::Sequel
      else
        raise TransactionalOutbox::UnsupportedAdapter, "Unsupported adapter: #{adapter}"
      end
    end
  end
end
