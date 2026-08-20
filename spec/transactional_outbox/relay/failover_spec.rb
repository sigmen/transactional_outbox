# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Relay::Failover do
  subject(:failover) { described_class.call(error, worker) }

  let(:error) { StandardError.new }
  let(:worker) { TransactionalOutbox::Relay::WorkersSet::Worker.new("test-topic") }

  it "raises an error" do
    expect { failover }.to raise_error error
  end
end
