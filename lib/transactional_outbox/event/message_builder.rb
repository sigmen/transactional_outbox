# frozen_string_literal: true

module TransactionalOutbox
  class Event
    class MessageBuilder
      def self.build(event, payload, *_context)
        config = event.class.config

        { topic: config.topic, event_type: config.event_type.to_s, payload: }
      end
    end
  end
end
