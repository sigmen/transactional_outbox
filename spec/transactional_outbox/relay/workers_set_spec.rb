# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Relay::WorkersSet do
  subject(:workers_set) { described_class.new }

  let(:worker_class) { TransactionalOutbox::Relay::WorkersSet::Worker }

  def stub_worker(stopped: false, shutting_down: false)
    instance_double(worker_class, stopped?: stopped, shutting_down?: shutting_down, shutdown: nil)
  end

  describe "#get_worker" do
    it "returns nil for an unknown topic" do
      expect(workers_set.get_worker("unknown")).to be_nil
    end
  end

  describe "#add_worker" do
    it "spawns and stores a worker for a topic without one" do
      worker = stub_worker
      allow(worker_class).to receive(:new).with("topic").and_return(worker)

      workers_set.add_worker("topic")

      expect(workers_set.get_worker("topic")).to eq(worker)
    end

    it "does not spawn a new worker if one already exists for the topic" do
      worker = stub_worker
      allow(worker_class).to receive(:new).with("topic").and_return(worker)

      workers_set.add_worker("topic")
      workers_set.add_worker("topic")

      expect(worker_class).to have_received(:new).once
    end
  end

  describe "#try_to_recover_worker" do
    it "does not replace a worker that is still alive" do
      alive_worker = stub_worker(stopped: false, shutting_down: false)
      allow(worker_class).to receive(:new).with("topic").and_return(alive_worker)
      workers_set.add_worker("topic")

      workers_set.try_to_recover_worker("topic")

      expect(worker_class).to have_received(:new).once
      expect(workers_set.get_worker("topic")).to eq(alive_worker)
    end

    it "does not replace a worker that stopped because of a deliberate shutdown" do
      shutdown_worker = stub_worker(stopped: true, shutting_down: true)
      allow(worker_class).to receive(:new).with("topic").and_return(shutdown_worker)
      workers_set.add_worker("topic")

      workers_set.try_to_recover_worker("topic")

      expect(worker_class).to have_received(:new).once
    end

    it "replaces a worker that stopped because it crashed" do
      crashed_worker = stub_worker(stopped: true, shutting_down: false)
      new_worker = stub_worker
      allow(worker_class).to receive(:new).with("topic").and_return(crashed_worker, new_worker)
      workers_set.add_worker("topic")

      workers_set.try_to_recover_worker("topic")

      expect(worker_class).to have_received(:new).twice
      expect(workers_set.get_worker("topic")).to eq(new_worker)
    end
  end

  describe "#stop_workers" do
    it "sends shutdown to every worker" do
      worker_a = stub_worker
      worker_b = stub_worker
      allow(worker_class).to receive(:new).and_return(worker_a, worker_b)
      workers_set.add_worker("a")
      workers_set.add_worker("b")

      workers_set.stop_workers

      expect(worker_a).to have_received(:shutdown)
      expect(worker_b).to have_received(:shutdown)
    end
  end

  describe "#all_stopped?" do
    it "is true when there are no workers" do
      expect(workers_set.all_stopped?).to be true
    end

    it "is false while any worker has not stopped yet" do
      running = stub_worker(stopped: false)
      stopped = stub_worker(stopped: true)
      allow(worker_class).to receive(:new).and_return(running, stopped)
      workers_set.add_worker("a")
      workers_set.add_worker("b")

      expect(workers_set.all_stopped?).to be false
    end

    it "is true once every worker has stopped" do
      worker = stub_worker(stopped: true)
      allow(worker_class).to receive(:new).and_return(worker)
      workers_set.add_worker("a")

      expect(workers_set.all_stopped?).to be true
    end
  end
end
