# frozen_string_literal: true

require_relative "relay/monitor"

module TransactionalOutbox
  class Relay
    def self.monitor = @monitor ||= TransactionalOutbox::Relay::Monitor.new
  end
end
