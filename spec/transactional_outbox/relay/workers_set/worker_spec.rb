# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Relay::WorkersSet::Worker do
  let(:worker) { described_class.new(topic) }
  let(:topic) { "test-topic" }

  describe "#shutdown" do
    subject(:shutdown) { worker.shutdown }

    before do
      worker.run
    end

    it "changes shutdown state" do
      expect { shutdown }.to change(worker, :shutting_down?).from(false).to(true)
    end
  end

  describe "#shutting_down?" do
    subject(:shutting_down?) { worker.shutting_down? }

    before do
      worker.run
    end

    context "when worker is shutting down" do
      before do
        worker.shutdown
      end

      it "returns true" do
        expect(shutting_down?).to be_truthy
      end
    end

    context "when worker is not shutting down" do
      it "returns false" do
        expect(shutting_down?).to be_falsey
      end
    end
  end

  describe "#stopped?" do
    subject(:stopped?) { worker.stopped? }

    before do
      worker.run
    end

    context "when worker is shutting down" do
      before do
        worker.instance_variable_get(:@thread)[:stopped] = true
      end

      it "returns true" do
        expect(stopped?).to be_truthy
      end
    end

    context "when worker is not shutting down" do
      it "returns false" do
        expect(stopped?).to be_falsey
      end
    end
  end

  describe "#run" do
    subject(:run) { worker.run }

    context "when everything is fine" do
      before do
        allow(Thread).to receive(:new).and_yield
      end

      it "calls event processor" do
        expect_any_instance_of(TransactionalOutbox::Relay::EventProcessor).to receive(:call).once.and_call_original

        run
      end
    end
  end
end
