# frozen_string_literal: true

class RunnerSpecLoopBreak < Exception; end # rubocop:disable Lint/InheritException

RSpec.describe TransactionalOutbox::Relay::Runner do
  subject(:runner) { described_class }

  let(:logger) { double("logger", info: nil, error: nil) }
  let(:config) { double("config", max_relay_runner_retries_count: 2, logger: logger) }
  let(:workers_set) do
    instance_double(
      TransactionalOutbox::Relay::WorkersSet,
      get_worker: nil,
      add_worker: nil,
      try_to_recover_worker: nil,
      stop_workers: nil,
      all_stopped?: true
    )
  end
  let(:repository) { instance_double(TransactionalOutbox::Repositories::OutboxEvent, fetch_topics: []) }

  before do
    allow(runner).to receive_messages(config: config, outbox_events_repo: repository, sleep: nil, exit: nil)
    allow(TransactionalOutbox::Relay::WorkersSet).to receive(:new).and_return(workers_set)
    allow(TransactionalOutbox::Relay::GracefulShutdown).to receive(:call)
  end

  describe "topic processing" do
    before { allow(runner).to receive(:loop) { |&block| block.call } }

    it "adds a worker for a topic that has none yet" do
      allow(repository).to receive(:fetch_topics).and_return(["orders"])
      allow(workers_set).to receive(:get_worker).with("orders").and_return(nil)

      runner.start

      expect(workers_set).to have_received(:add_worker).with("orders")
      expect(workers_set).not_to have_received(:try_to_recover_worker)
    end

    it "tries to recover a topic that already has a worker" do
      existing_worker = instance_double(TransactionalOutbox::Relay::WorkersSet::Worker)
      allow(repository).to receive(:fetch_topics).and_return(["orders"])
      allow(workers_set).to receive(:get_worker).with("orders").and_return(existing_worker)

      runner.start

      expect(workers_set).to have_received(:try_to_recover_worker).with("orders")
      expect(workers_set).not_to have_received(:add_worker)
    end
  end

  describe "error handling" do
    it "retries on a transient error and keeps polling without shutting down" do
      call_count = 0
      allow(repository).to receive(:fetch_topics) do
        call_count += 1
        case call_count
        when 1 then raise "temporary db hiccup"
        when 2 then []
        else raise RunnerSpecLoopBreak
        end
      end

      expect { runner.start }.to raise_error(RunnerSpecLoopBreak)

      expect(repository).to have_received(:fetch_topics).exactly(3).times
      expect(TransactionalOutbox::Relay::GracefulShutdown).not_to have_received(:call)
      expect(runner).not_to have_received(:exit)
    end

    it "gives up and shuts down gracefully after exceeding the retry limit" do
      allow(repository).to receive(:fetch_topics).and_raise("db is down")

      runner.start

      expect(repository).to have_received(:fetch_topics).exactly(3).times
      expect(TransactionalOutbox::Relay::GracefulShutdown).to have_received(:call).with(workers_set)
      expect(runner).to have_received(:exit).with(1)
    end

    it "shuts down cleanly on an OS signal without retrying" do
      allow(repository).to receive(:fetch_topics).and_raise(SignalException.new("TERM"))

      runner.start

      expect(repository).to have_received(:fetch_topics).once
      expect(TransactionalOutbox::Relay::GracefulShutdown).to have_received(:call).with(workers_set)
      expect(runner).to have_received(:exit).with(0)
    end
  end
end
