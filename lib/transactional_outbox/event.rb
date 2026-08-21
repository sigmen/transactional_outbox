# frozen_string_literal: true

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
    setting :event_builder

    config.values.keys.each do |attr|
      define_singleton_method(attr) do |value|
        config[attr] = value
      end
    end

    def create!(context)
      validate_context!(context)

      event = build_event(context)

      save([event])
    end

    def bulk_create!(contexts)
      validate_contexts!(contexts)

      events = build_events(contexts)

      save(events)
    end

    private

    def config = @config ||= self.class.config

    def event_builder
      @event_builder ||= begin
        klass = config.event_builder || TransactionalOutbox.config.default_event_builder

        Object.const_get(klass)
      end
    end

    def save(rows) = TransactionalOutbox::Database.new.insert_events(rows)

    def validate_event(schema, payload)
      return true if config.schema.nil?

      errors = JSON::Validator.fully_validate(schema, payload)

      return true if errors.empty?

      raise TransactionalOutbox::InvalidPayloadError, errors.join(", ")
    end

    def build_event(context)
      payload = build_payload(context)

      validate_event(config.schema, payload)

      event_builder.build(self.class.config, payload, context)
    end

    def build_events(contexts) = contexts.map { build_event(_1) }

    def validate_contexts!(contexts) = contexts.each { |context| validate_context!(context) }
  end
end
