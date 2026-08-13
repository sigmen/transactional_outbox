# frozen_string_literal: true

require_relative "producer/adapters/interface"
require_relative "producer/adapters/karafka"
require_relative "producer/adapters/null"

module TransactionalOutbox
  class Producer
    extend Forwardable

    def_delegators :@adapter, :produce_batch

    def initialize
      @adapter = get_adapter
    end

    private

    def get_adapter
      return Adapters::Null.new if TransactionalOutbox.config.test_environment

      TransactionalOutbox.config.producer.adapter
    end
  end
end
