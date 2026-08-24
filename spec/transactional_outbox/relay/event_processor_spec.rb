# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Relay::EventProcessor do
  subject(:event_processor) { instance.call }

  let(:queue) { "test-queue" }
  let(:instance) { described_class.new(queue) }
  let(:events_count) { 1 }

  before do
    gen_events(queue, events_count)
  end

  it "produces messages" do
    expect { event_processor }
      .to change(instance.producer.adapter.messages, :size)
      .from(0).to(events_count)
  end

  it "deletes messages after processing" do
    expect { event_processor }
      .to change(TransactionalOutbox::Database::Adapters::Null.dataset, :size)
      .from(events_count).to(0)
  end

  it "publishes event to monitor" do
    expect(TransactionalOutbox::Relay.monitor)
      .to receive(:publish)
      .with("worker.events.processed", { count: events_count, queue: })
      .once

    event_processor
  end

  context "when no events exist" do
    let(:events_count) { 0 }

    it "doesnt produce messages" do
      expect { event_processor }.not_to change(instance.producer.adapter.messages, :size)
    end

    it "doesnt publish event to monitor" do
      expect(TransactionalOutbox::Relay.monitor).not_to receive(:publish)

      event_processor
    end
  end

  context "when raises an error" do
    before do
      allow_any_instance_of(TransactionalOutbox::Database).to receive(:fetch_events).and_raise(StandardError)
    end

    it "calls failover" do
      expect(TransactionalOutbox.config.relay.failover).to receive(:call).once.and_call_original

      event_processor rescue nil
    end

    it "doesnt publish event to monitor" do
      expect(TransactionalOutbox::Relay.monitor)
        .to receive(:publish)
        .with("worker.exceptions_total", { exception: "StandardError", queue: })

      event_processor rescue nil
    end
  end
end
