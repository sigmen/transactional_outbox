# frozen_string_literal: true

module Outbox
  module Events
    module User
      class Created < TransactionalOutbox::Event
        schema JSON.load_file("#{Dir.pwd}/spec/fixtures/event_schema.json")
        aggregate_type "user"
        event_type "created"
        queue "user-queue"

        context do
          required(:user).value(type?: ::User)
        end

        prepare_payload do |context|
          prepare_user(context[:user])
        end

        private

        def prepare_user(user)
          {
            id: user.id,
            name: user.name
          }
        end
      end
    end
  end
end
