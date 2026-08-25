# frozen_string_literal: true

require_relative "interface"
require_relative "instance_methods"

module TransactionalOutbox
  class Database
    class Adapters
      class Base < Interface
        include InstanceMethods
      end
    end
  end
end
