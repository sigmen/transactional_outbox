# frozen_string_literal: true

module TransactionalOutbox
  class Event
    class MessageBuilder
      def self.build(event, payload, *_extra_args)
        { id: SecureRandom.uuid, topic: event.config.topic, event_type: event.config.event_type, payload: }
      end
    end
  end
end
