# frozen_string_literal: true

namespace :relay do
  desc "Runs transactional outbox event relay"
  task run: :environment do
    TransactionalOutbox::Relay::Runner.start
  end
end
