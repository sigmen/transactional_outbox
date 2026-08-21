# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Relay::Runner do
  subject(:runner) { described_class.start }

  it "calls worker set processor" do
    expect_any_instance_of(TransactionalOutbox::Relay::WorkerSet::Processor).to receive(:call).once.and_call_original

    runner
  end

  it "publish an init runner event" do
    expect(TransactionalOutbox::Relay.monitor).to receive(:publish).with("runner.init").once

    runner
  end

  context "when received standard error exception" do
    before do
      allow_any_instance_of(TransactionalOutbox::Relay::WorkerSet::Processor).to receive(:call).and_raise(StandardError)
    end

    it "calls graceful shutdown" do
      expect(TransactionalOutbox::Relay::GracefulShutdown).to receive(:call).once.and_call_original

      runner
    end
  end

  context "when received signal exception" do
    before do
      allow_any_instance_of(TransactionalOutbox::Relay::WorkerSet::Processor).to receive(:call).and_raise(SignalException.new(0))
    end

    it "calls graceful shutdown" do
      expect(TransactionalOutbox::Relay::GracefulShutdown).to receive(:call).once.and_call_original

      runner
    end
  end
end
