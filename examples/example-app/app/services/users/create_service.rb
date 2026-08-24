# frozen_string_literal: true

module Users
  class CreateService
    def call
      TransactionalOutbox.outboxable do
        user = User.create!(id:, name:)

        Outbox::Events::User::CreatedEvent.new.create!(user:)
      end
    end
  end
end
