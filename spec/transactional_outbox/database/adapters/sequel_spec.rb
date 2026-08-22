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

    let(:events) { [{ id: Random.uuid, payload: {}.to_json }] }

    it "inserts messages" do
      expect { insert_events }.to change(Sequel::Model(:outbox_events), :count).from(0).to(1)
    end
  end

  describe "#fetch_topics" do
    subject(:fetch_topics) { described_class.new.fetch_topics }

    let(:topic) { "test-topic" }

    before do
      Sequel::Model(:outbox_events).insert(id: SecureRandom.uuid, topic:)
    end

    it "returns topics" do
      expect(fetch_topics).to match_array [topic]
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
    subject(:fetch_events) { described_class.new.fetch_events(topic, 1) }

    let(:id) { SecureRandom.uuid }
    let(:topic) { "test-topic" }
    let(:aggregate_id) { SecureRandom.uuid }
    let(:aggregate_type) { "user" }
    let(:event_type) { "created" }
    let(:event1) do
      {
        id:,
        topic:,
        aggregate_id:,
        aggregate_type:,
        event_type:,
        headers: "{}",
        created_at: Time.now.utc,
        payload: { id: aggregate_id }.to_json
      }
    end

    let(:event2) do
      {
        id: SecureRandom.uuid,
        topic: "test-topic-2",
        aggregate_id: SecureRandom.uuid,
        aggregate_type:,
        event_type:,
        headers: "{}",
        created_at: Time.now.utc,
        payload: { id: SecureRandom.uuid }.to_json
      }
    end

    before do
      Sequel::Model(:outbox_events).multi_insert([event1, event2])
    end

    it "returns events filtered by topic" do
      ids = fetch_events.map { |e| e[:id] }

      expect(ids).to eq [event1[:id]]
    end
  end
end
