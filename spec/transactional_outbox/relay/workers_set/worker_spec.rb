# frozen_string_literal: true

require "timeout"

RSpec.describe TransactionalOutbox::Relay::WorkersSet::Worker do
  subject(:worker) { described_class.new(topic) }
end
