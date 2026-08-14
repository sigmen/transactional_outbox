# frozen_string_literal: true

module TransactionalOutbox
  module Constants
    EVENT_TYPES = %w[created updated deleted].freeze
    ALLOWED_FOR_GEN_MIGRATION_ADAPTERS = %i[active_record sequel].freeze
  end
end
