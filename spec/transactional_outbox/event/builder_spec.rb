# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Event::Builder do
  subject { described_class.build(event_config, payload, context) }

  let(:event_config) do
    double(aggregate_type: "user", queue: "test-queue", queue_extra_parameters: nil, event_type: "created")
  end

  let(:context) { { user: { id: user_id } } }
  let(:user_id) { SecureRandom.uuid }
  let(:payload) { { user: { id: user_id, foo: "bar" } } }
  let(:id) { "91e5ed4a-5405-4605-8a8d-e4c9fb7f26be" }

  let(:result) do
    {
      id:,
      aggregate_type: "user",
      aggregate_id: user_id,
      queue: "test-queue",
      queue_extra_parameters: nil,
      event_type: "created",
      headers: {},
      payload:
    }
  end

  before do
    allow(SecureRandom).to receive(:uuid).and_return(id)
  end

  it { is_expected.to eq result }
end
