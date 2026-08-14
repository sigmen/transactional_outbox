# frozen_string_literal: true

require "transactional_outbox"

require_relative "support/config"
require_relative "support/outbox_events"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:each) do
    TransactionalOutbox::Database::Adapters::Null.clear_store
    TransactionalOutbox::Producer::Adapters::Null.clear_store
  end
end
