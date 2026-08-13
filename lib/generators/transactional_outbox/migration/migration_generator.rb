# frozen_string_literal: true

module TransactionalOutbox
  class MigrationGenerator
    include Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    def self.next_migration_number(_dirname) = Time.now.utc.strftime("%Y%m%d%H%M%S")

    def create_migration_file
      migration_name = "create_outbox_events_table"
      migration_file = File.join(TransactionalOutbox.config.migrations_directory, "#{migration_name}.rb")

      migration_template("sequel.rb.erb", migration_file)
    end
  end
end
