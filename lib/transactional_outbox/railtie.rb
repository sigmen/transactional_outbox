# frozen_string_literal: true

module TransactionalOutbox
  class Railtie < ::Rails::Railtie
    generators do
      require_relative "../generators/transactional_outbox/migration/migration_generator.rb"
    end
  end
end
