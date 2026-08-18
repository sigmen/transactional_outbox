# frozen_string_literal: true

module TransactionalOutbox
  module Constants
    EVENT_TYPES = %i[created updated deleted].freeze
    ALLOWED_FOR_GEN_MIGRATION_ADAPTERS = %i[active_record sequel].freeze
    DEFAULT_PAYLOAD_BUILDER_BLOCK = -> { _1 }
  end
end
