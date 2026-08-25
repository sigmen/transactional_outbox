# frozen_string_literal: true

module Outbox
  module Events
    module User
      class CreatedEvent < TransactionalOutbox::Event
        aggregate_type "user"
        event_type "created"
        queue "users"
        schema JSON.load_file(Rails.root.join("app/schemas/user.schema.json"))
        event_builder Outbox::Events::Builder

        context do
          required(:user).hash do
            required(:id).filled(:string)
            required(:name).filled(:string)
          end
        end

        prepare_payload do |context|
          { user: prepare_user(context) }
        end

        private

        def prepare_user(context)
          context[:user] => { id:, name: }

          { id:, name: }
        end
      end
    end
  end
end
