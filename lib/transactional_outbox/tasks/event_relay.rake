# frozen_string_literal: true

namespace :event_relay do
  desc "Runs transactional outbox event relay"
  task run: :environment do
    TransactionalOutbox::Relay::Runner.start
  end
end
