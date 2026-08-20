# frozen_string_literal: true

module TransactionalOutbox
  module Constants
    BASE_DATABASE_ADAPTERS = %w[active_record sequel null].freeze
    BASE_PRODUCER_ADAPTERS = %w[karafka null].freeze
    DEFAULT_PAYLOAD_BUILDER_BLOCK = -> { _1 }
  end
end
