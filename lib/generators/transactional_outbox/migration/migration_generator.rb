# frozen_string_literal: true

module TransactionalOutbox
  class MigrationGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    def self.next_migration_number(_dirname) = Time.now.utc.strftime("%Y%m%d%H%M%S")

    def create_migration_file
      adapter = TransactionalOutbox.config.db.adapter

      unless File.exist?("#{File.expand_path("templates", __dir__)}/#{adapter}.rb.erb")
        raise TransactionalOutbox::MigrationFileNotExistsError, "Migration template not exists for adapter: #{adapter}"
      end

      migration_name = "create_outbox_events_table"
      migration_file = File.join(TransactionalOutbox.config.migrations_directory, "#{migration_name}.rb")

      migration_template("#{adapter}.rb.erb", migration_file)
    end
  end
end
