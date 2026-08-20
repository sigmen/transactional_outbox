# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Relay::WorkersSet do
  subject(:get_worker) { instance.get_worker(topic) }
  subject(:add_worker) { instance.add_worker(topic) }

  let(:topic) { "test-topic" }
  let(:instance) { described_class.new }
  let(:workers) { instance.instance_variable_get(:@workers) }

  describe "#get_worker" do
    before do
      add_worker
    end

    it "successful gets worker" do
      worker = add_worker

      expect(get_worker).to eq worker
    end
  end

  describe "#add_worker" do
    it "returns new worker" do
      expect(add_worker).to be_a described_class::Worker
    end

    it "adds worker" do
      expect { add_worker }.to change(workers, :size).from(0).to(1)
    end

    context "when worker already exists" do
      before do
        add_worker
      end

      it "doesnt add worker" do
        expect { add_worker }.not_to change(workers, :size)
      end
    end
  end

  describe "#try_to_recover_worker" do
    subject(:try_to_recover_worker) { instance.try_to_recover_worker(topic) }

    let!(:worker) { add_worker }
    let(:thread) { worker.instance_variable_get(:@thread) }
    let(:stopped) { true }

    before do
      thread[:stopped] = stopped if thread
    end

    it "returns not equal worker" do
      try_to_recover_worker

      expect(get_worker).not_to eq worker
    end

    context "when worker is not stopped" do
      let(:stopped) { false }

      it "doesnt replace worker" do
        try_to_recover_worker

        expect(get_worker).to eq worker
      end
    end

    context "when worker doesnt exist" do
      let(:worker) { nil }

      it "returns new worker" do
        expect(add_worker).to be_a described_class::Worker
      end

      it "adds worker" do
        expect { add_worker }.to change(workers, :size).from(0).to(1)
      end
    end

    context "when worker has shutting down state" do
      let(:stopped) { false }

      before do
        thread[:shutdown] = true
      end

      it "doesnt replace worker" do
        try_to_recover_worker

        expect(get_worker).to eq worker
      end

      it "doesnt add worker" do
        expect { add_worker }.not_to change(workers, :size)
      end

      context "when stopped" do
        let(:stopped) { true }

        it "doesnt replace worker" do
          try_to_recover_worker

          expect(get_worker).to eq worker
        end

        it "doesnt add worker" do
          expect { add_worker }.not_to change(workers, :size)
        end
      end
    end
  end

  describe "#stop_workers" do
    subject(:stop_workers) { instance.stop_workers }

    let!(:worker) { add_worker }

    it "stops workers" do
      stop_workers

      expect(worker.shutting_down?).to be_truthy
    end
  end

  describe "#all_stopped?" do
    subject(:all_stopped?) { instance.all_stopped? }

    let!(:worker) { add_worker }

    context "when all workers are stopped" do
      before do
        worker.instance_variable_get(:@thread)[:stopped] = true
      end

      it "returns true" do
        expect(all_stopped?).to be_truthy
      end
    end

    context "when all workers arent stopped" do
      it "returns false" do
        expect(all_stopped?).to be_falsey
      end
    end
  end
end
