# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Database::Adapters::Sequel do
  around do |example|
    Sequel::Model.db.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end

  describe "#transaction" do
    subject(:tx) { described_class.new.transaction { :ok } }

    it "returns ok" do
      expect(tx).to eq :ok
    end
  end

  describe "#insert_events" do
    subject(:insert_events) { described_class.new.insert_events(events) }

    let(:events) { [{ id: Random.uuid, status: "new", payload: {}.to_json }] }

    it "inserts messages" do
      expect { insert_events }.to change(Sequel::Model(:outbox_events), :count).from(0).to(1)
    end
  end

  describe "#fetch_queues" do
    subject(:fetch_queues) { described_class.new.fetch_queues }

    let(:queue) { "test-queue" }
    let(:status) { "new" }
    let(:processing_started_at) { nil }

    before do
      Sequel::Model(:outbox_events).insert(id: SecureRandom.uuid, queue:, status:, processing_started_at:)
    end

    it "returns queues" do
      expect(fetch_queues).to match_array [queue]
    end

    context "when event has processing status" do
      let(:status) { "processing" }
      let(:processing_started_at) { Time.now.utc - 3600 }

      it "returns queues" do
        expect(fetch_queues).to match_array [queue]
      end

      context "when event is fresh" do
        let(:processing_started_at) { Time.now.utc }

        it "returns empty queues" do
          expect(fetch_queues).to be_empty
        end
      end
    end
  end

  describe "#delete_events" do
    subject(:delete_events) { described_class.new.delete_events([id]) }

    let(:id) { SecureRandom.uuid }

    before do
      Sequel::Model(:outbox_events).insert(id:)
    end

    it "deletes events" do
      expect { delete_events }.to change(Sequel::Model(:outbox_events), :count).from(1).to(0)
    end
  end

  describe "#fetch_events" do
    subject(:fetch_events) { described_class.new.fetch_events(queue, 1) }

    let(:id) { SecureRandom.uuid }
    let(:queue) { "test-queue" }
    let(:aggregate_id) { SecureRandom.uuid }
    let(:aggregate_type) { "user" }
    let(:event_type) { "created" }
    let(:processing_started_at) { nil }
    let(:status) { "new" }
    let(:event1) do
      {
        id:,
        queue:,
        aggregate_id:,
        aggregate_type:,
        event_type:,
        status:,
        headers: "{}",
        created_at: Time.now.utc,
        payload: { id: aggregate_id }.to_json,
        processing_started_at:
      }
    end

    let(:event2) do
      {
        id: SecureRandom.uuid,
        queue: "test-queue-2",
        aggregate_id: SecureRandom.uuid,
        aggregate_type:,
        event_type:,
        status: "new",
        headers: "{}",
        created_at: Time.now.utc,
        payload: { id: SecureRandom.uuid }.to_json
      }
    end

    before do
      Sequel::Model(:outbox_events).multi_insert([event1, event2])
    end

    it "returns events filtered by queue" do
      ids = fetch_events.map { |e| e[:id] }

      expect(ids).to eq [event1[:id]]
    end

    context "when event has processing status" do
      let(:status) { "processing" }
      let(:processing_started_at) { Time.now.utc - 3600 }

      it "returns events filtered by queue and processing started at timestamp" do
        ids = fetch_events.map { |e| e[:id] }

        expect(ids).to eq [event1[:id]]
      end

      context "when event is fresh" do
        let(:processing_started_at) { Time.now.utc }

        it "returns empty dataset" do
          expect(fetch_events).to be_empty
        end
      end
    end
  end
end
