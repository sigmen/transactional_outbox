# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Producer::Adapters::Kafka do
  describe "#produce_batch" do
    subject(:produce_batch) { described_class.new(kafka).produce_batch(topic, events) }

    let(:kafka) { Kafka.new(seed_brokers: "localhost") }
    let(:topic) { "test-topic" }
    let(:events) { [{ id: SecureRandom.uuid, payload: "{}" }] }

    before do
      allow_any_instance_of(Kafka::Producer).to receive(:deliver_messages).and_return(true)
    end

    it { is_expected.to be_truthy }
  end
end
