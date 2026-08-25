# frozen_string_literal: true

module Outbox
  class Failover
    def self.call(exception, _events)
      Sentry.capture_exception(exception)
    end
  end
end
