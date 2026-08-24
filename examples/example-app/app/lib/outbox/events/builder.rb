# frozen_string_literal: true

module Outbox
  module Events
    class Builder
      def self.build(event_config, payload, _context)
        {
          id: SecureRandom.uuid,
          queue: event_config.queue,
          queue_extra_parameters: event_config.queue_extra_parameters,
          aggregate_type: event_config.aggregate_type,
          event_type: event_config.event_type.to_s,
          headers: {},
          payload:
        }
      end
    end
  end
end
