# frozen_string_literal: true

module TransactionalOutbox
  class Railtie < ::Rails::Railtie
    generators do
      require_relative "../generators/transactional_outbox/migration/migration_generator.rb"
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), "tasks/*.rake")].each { |f| load f }
    end
  end
end
