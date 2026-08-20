# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Event::MessageBuilder do
  subject(:build_message) { described_class.build(event_config, payload, context) }

  let(:event_config) { double(aggregate_type: "test", topic: "test-topic", event_type: "created") }
  let(:context) { [] }
  let(:payload) { { foo: "bar" } }

  let(:result) do
    {
      aggregate_type: "test",
      topic: "test-topic",
      event_type: "created",
      headers: {},
      payload:
    }
  end

  it { is_expected.to eq result }
end
