# frozen_string_literal: true

module TransactionalOutbox
  class Producer
    class Adapters
      module InstanceMethods
        def initialize(connection_config)
          @connection_config = connection_config
        end

        private

        attr_reader :connection_config
      end
    end
  end
end
