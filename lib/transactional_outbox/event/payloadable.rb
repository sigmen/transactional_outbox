# frozen_string_literal: true

module TransactionalOutbox
  class Event
    module Payloadable
      def self.extended(klass)
        klass.define_method(:build_payload) do |context|
          builder = self.class.instance_variable_get(:@__payload_builder__) ||
            TransactionalOutbox::DEFAULT_PAYLOAD_BUILDER_BLOCK

          instance_exec(context, &builder)
        end
      end

      def payload(&block) = @__payload_builder__ ||= block
    end
  end
end
