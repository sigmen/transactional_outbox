# frozen_string_literal: true

module TransactionalOutbox
  class Event
    class Builder
      def self.build(event_config, payload, _context)
        {
          topic: event_config.topic,
          aggregate_type: event_config.aggregate_type,
          event_type: event_config.event_type.to_s,
          headers: {},
          payload:
        }
      end
    end
  end
end
