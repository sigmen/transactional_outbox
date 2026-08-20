# frozen_string_literal: true

module TransactionalOutbox
  class Event
    module Contextable
      attr_reader :context_schema

      def self.extended(klass)
        klass.define_method(:validate_context!) do |params|
          ctx_schema = self.class.instance_variable_get(:@__context_schema__)

          return true unless ctx_schema

          result = ctx_schema.call(params)

          self.class.check_context_validation_result!(result)
        end
      end

      def check_context_validation_result!(result)
        return true if result.success?

        errors = result.message_set.messages.map do |message|
          "#{message.path.join("->")} #{message.text}"
        end.join(", ")

        raise TransactionalOutbox::InvalidContextError, "Invalid context error: #{errors}"
      end

      def context(&block)
        @__context_schema__ ||= Class.new(Dry::Validation::Contract).class_exec { params(&block) } if block
      end
    end
  end
end
