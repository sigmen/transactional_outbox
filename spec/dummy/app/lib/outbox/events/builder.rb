# frozen_string_literal: true

module Outbox
  module Events
    class Builder
      def self.build(event_config, payload, context)
        {
          id: SecureRandom.uuid,
          queue: event_config.queue,
          aggregate_type: event_config.aggregate_type,
          aggregate_id: context[:user].id,
          event_type: event_config.event_type,
          headers: {}.to_json,
          payload: payload.to_json
        }
      end
    end
  end
end
