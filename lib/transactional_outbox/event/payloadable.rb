# frozen_string_literal: true

module TransactionalOutbox
  class Event
    module Payloadable
      def self.extended(klass)
        klass.define_method(:build_payload) do |context|
          self.class.instance_variable_get(:@__payload_builder__).call(context)
        end
      end

      def payload(&block) = @__payload_builder__ ||= block || TransactionalOutbox::Contants::DEFAULT_PAYLOAD_BUILDER_BLOCK
    end
  end
end
