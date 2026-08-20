# frozen_string_literal: true

module TransactionalOutbox
  class Railtie < ::Rails::Railtie
    generators do
      require_relative "../generators/transactional_outbox/migration_generator"
    end
  end
end
