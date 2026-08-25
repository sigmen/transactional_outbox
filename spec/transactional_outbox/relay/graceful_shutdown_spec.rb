# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Relay::GracefulShutdown do
  subject(:shutdown) { described_class.call(worker_set, exit_code) }

  let(:worker_set) do
    instance_double(TransactionalOutbox::Relay::WorkerSet, stop_workers: true, all_stopped?: all_stopped)
  end

  let(:exit_code) { 0 }
  let(:all_stopped) { true }
  let(:shutdown_waiting_time_seconds) { 0.05 }

  before do
    allow(TransactionalOutbox.config)
      .to receive(:shutdown_waiting_time_seconds)
      .and_return(shutdown_waiting_time_seconds)
  end

  it "requests all workers to stop" do
    shutdown

    expect(worker_set).to have_received(:stop_workers)
  end

  it "returns exit code as soon as every worker has stopped" do
    expect(shutdown).to eq exit_code
  end

  context "gives up after the configured waiting time if workers never stop" do
    let(:all_stopped) { false }

    it "returns nil" do
      expect(shutdown).to be_nil
    end
  end
end
