# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    extend Forwardable

    def_delegators :@adapter, :produce_batch

    attr_reader :adapter

    def initialize
      @adapter = TransactionalOutbox::Producer::Adapters.resolve(fetch_adapter).new(fetch_client)
    end

    private

    def config = @config ||= TransactionalOutbox.config

    def fetch_adapter
      return :null if config.test_environment

      config.producer.adapter.to_sym
    end

    def fetch_client
      return if config.test_environment

      config.producer.client
    end
  end
end
