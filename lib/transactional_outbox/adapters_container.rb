# frozen_string_literal: true

module TransactionalOutbox
  class AdaptersContainer
    class << self
      def resolve(adapter)
        return container.resolve(adapter) if exists?(adapter)

        raise TransactionalOutbox::UnknownAdapterError, "Unknown adapter: #{adapter}"
      end

      def register(adapter, klass)
        return container.register(adapter, klass) unless exists?(adapter)

        raise TransactionalOutbox::AdapterAlreadyExistsError, "Adapter already exists: #{adapter}"
      end

      private

      def container = @container ||= Dry::Container.new
      def exists?(adapter) = container.key?(adapter)
    end
  end
end
