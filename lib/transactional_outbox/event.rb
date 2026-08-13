# frozen_string_literal: true

require_relative "event/message_builder"

module TransactionalOutbox
  class Event
    extend Dry::Configurable

    setting :schema
    setting :event_type
    setting :topic
    setting :message_builder, default: MessageBuilder

    config.values.keys.each do |attr|
      define_singleton_method(attr) do |value|
        config[attr] = value
      end
    end

    def create!(payload, *extra_args)
      event = build(payload, *extra_args)

      save(event)
    end

    def build(payload, *extra_args)
      event_type = config.event_type

      validate_event_type(event_type)
      validate_event(config.schema, payload)

      config.message_builder.build(self, payload, *extra_args)
    end

    private

    def config = @config ||= self.class.config

    def save(event) = TransactionalOutbox::Database.insert(event)

    def validate_event(schema, payload)
      return true unless config.schema.nil?

      errors = JSON::Validator.fully_validate(schema, payload)

      return true if errors.empty?

      raise TransactionalOutbox::InvalidPayloadError, errors.join(", ")
    end

    def validate_event_type(event_type)
      return if TransactionalOutbox::Constants::EVENT_TYPES.include?(event_type.to_sym)

      raise TransactionalOutbox::UnsupportedEventType, "Unsupported event type: #{event_type}"
    end
  end
end
