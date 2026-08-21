# frozen_string_literal: true

module TransactionalOutbox
  module Constants
    BASE_DATABASE_ADAPTERS = %w[active_record sequel null].freeze
    BASE_PRODUCER_ADAPTERS = %w[kafka null].freeze
    DEFAULT_PAYLOAD_BUILDER_BLOCK = -> { _1 }

    RUNNER_INIT_MONITOR_EVENT = "runner.init".freeze
    RUNNER_STOPPED_MONITOR_EVENT = "runner.stopped".freeze
    WORKER_RUN_MONITOR_EVENT = "worker.run".freeze
    WORKER_STOPPED_MONITOR_EVENT = "worker.stopped".freeze
    WORKER_EVENTS_PROCESSED_MONITOR_EVENT = "worker.events.processed".freeze
  end
end

