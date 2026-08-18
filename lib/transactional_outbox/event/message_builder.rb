# frozen_string_literal: true

module TransactionalOutbox
  class Event
    class MessageBuilder
      def self.build(event_config, payload, *_context)
        { topic: event_config.topic, event_type: event_config.event_type.to_s, payload: }
      end
    end
  end
end
