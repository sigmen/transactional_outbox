# frozen_string_literal: true

require_relative "producer/adapters/interface"
require_relative "producer/adapters/karafka"
require_relative "producer/adapters/null"

module TransactionalOutbox
  class Producer
    extend Forwardable

    def_delegators :@adapter, :produce_batch

    def initialize(adapter = TransactionalOutbox.config.producer.adapter)
      @adapter = get_adapter_klass(adapter).new(TransactionalOutbox.config.producer.producer)
    end

    private

    def get_adapter_klass(adapter)
      case adapter.to_sym
      when :null then Adapters::Null
      when :karafka then Adapters::Karafka
      else
        raise TransactionalOutbox::UnsupportedAdapter, "Unsupported adapter: #{adapter}"
      end
    end
  end
end
