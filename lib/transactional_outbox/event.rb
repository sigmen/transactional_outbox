# frozen_string_literal: true

require_relative "event/message_builder"
require_relative "event/contextable"
require_relative "event/payloadable"

module TransactionalOutbox
  class Event
    extend Dry::Configurable
    extend Contextable
    extend Payloadable

    setting :schema
    setting :aggregate_type
    setting :event_type
    setting :topic
    setting :message_builder, default: MessageBuilder

    config.values.keys.each do |attr|
      define_singleton_method(attr) do |value|
        config[attr] = value
      end
    end

    def create!(context)
      validate_context!(context)

      event = build_message(context)

      save([event])
    end

    def create_batch!(contexts)
      validate_contexts!(contexts)

      batch = build_batch(contexts)

      save(batch)
    end

    private

    def config = @config ||= self.class.config

    def save(rows) = TransactionalOutbox::Repositories::OutboxEvent.new.insert(rows)

    def validate_event(schema, payload)
      return true if config.schema.nil?

      errors = JSON::Validator.fully_validate(schema, payload)

      return true if errors.empty?

      raise TransactionalOutbox::InvalidPayloadError, errors.join(", ")
    end

    def validate_event_type(event_type)
      return if TransactionalOutbox::Constants::EVENT_TYPES.include?(event_type.to_sym)

      raise TransactionalOutbox::UnsupportedEventTypeError, "Unsupported event type: #{event_type}"
    end

    def build_message(context)
      event_type = config.event_type
      payload = build_payload(context)

      validate_event_type(event_type)
      validate_event(config.schema, payload)

      config.message_builder.build(self, payload, context)
    end

    def build_batch(contexts) = contexts.map { build_message(_1) }
  end
end
