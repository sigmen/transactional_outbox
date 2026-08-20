# frozen_string_literal: true

module TransactionalOutbox
  module Constants
    BASE_DATABASE_ADAPTERS = %w[active_record sequel null].freeze
    BASE_PRODUCER_ADAPTERS = %w[karafka null].freeze
    ALLOWED_FOR_GEN_MIGRATION_ADAPTERS = %w[active_record sequel].freeze
    DEFAULT_PAYLOAD_BUILDER_BLOCK = -> { _1 }
  end
end
