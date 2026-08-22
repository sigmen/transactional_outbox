# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Relay::WorkerSet::Processor do
  subject(:processor) { instance.call }

  let(:instance) { described_class.new(worker_set) }
  let(:worker_set) { TransactionalOutbox::Relay::WorkerSet.new }
  let(:topic) { "test-topic" }

  before do
    gen_events(topic, 1)
  end

  it "spawns workers" do
    processor

    expect(worker_set.get_worker(topic)).to be_a TransactionalOutbox::Relay::WorkerSet::Worker
  end

  context "when raised an error" do
    before do
      expect(worker_set).to receive(:add_worker).and_raise(StandardError).twice
    end

    it "raises an error when retries has over" do
      expect { processor }.to raise_error StandardError
    end

    it "increases retry counter" do
      processor rescue nil

      expect(instance.instance_variable_get(:@retry_counter))
        .to eq TransactionalOutbox.config.max_relay_runner_retries_count
    end
  end
end
