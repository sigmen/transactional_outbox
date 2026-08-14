# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      class << self
        def resolve(adapter)
          container.resolve(adapter)
        rescue Dry::Container::KeyError
          raise TransactionalOutbox::UnknownProducerAdapterError, "Unknown producer adapter: #{adapter}"
        end

        def register(adapter, klass)
          container.register(adapter, klass)
        end

        private

        def container = @container ||= Dry::Container.new
      end
    end
  end
end
