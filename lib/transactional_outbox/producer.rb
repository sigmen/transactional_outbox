# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    extend Forwardable

    def_delegators :@adapter, :produce_batch, :close

    attr_reader :adapter

    def initialize
      @adapter = TransactionalOutbox::Producer::Adapters.resolve(fetch_adapter).new(config.producer.connection_config)
    end

    private

    def config = @config ||= TransactionalOutbox.config

    def fetch_adapter
      return :null if config.test_environment

      config.producer.adapter.to_sym
    end
  end
end
