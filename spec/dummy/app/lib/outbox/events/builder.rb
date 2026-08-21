module Outbox
  module Events
    class Builder
      def self.build(event_config, payload, context)
        {
          id: SecureRandom.uuid,
          topic: event_config.topic,
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
