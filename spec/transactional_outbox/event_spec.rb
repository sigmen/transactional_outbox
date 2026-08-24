# frozen_string_literal: true

RSpec.describe TransactionalOutbox::Event do
  shared_context "event creation common cases" do
    context "when everything is correct" do
      include_context "success way"
    end

    context "when event has invalid context" do
      let(:context) { { foo: "bar" } }

      include_context "failure way", TransactionalOutbox::Exceptions::InvalidContextError
    end

    context "when payload is invalid" do
      let(:payload_block) { short_payload_block }

      include_context "failure way", TransactionalOutbox::Exceptions::InvalidPayloadError

      context "when payload schema is empty" do
        let(:payload_schema) { nil }
        let(:correct_event_data) { short_correct_event_data }

        include_context "success way"
      end
    end
  end

  shared_context "success way" do
    it "saves an event" do
      expect { subject }.to change(dataset, :size).from(0).to(1)
    end

    it "returns correct event" do
      events = subject

      expect(events.last.except(:id)).to eq correct_event_data
    end
  end

  shared_context "failure way" do |exception_class|
    it "raises an error" do
      expect { subject }.to raise_error exception_class
    end

    it "doesnt save an event" do
      expect { subject rescue nil }.not_to change(dataset, :size)
    end
  end

  let(:database) { TransactionalOutbox::Database.new }
  let(:dataset) { TransactionalOutbox::Database::Adapters::Null.dataset }

  let(:event_class) do
    define_event(payload_schema, aggregate_type, event_type, queue, event_builder_class, payload_block)
  end

  let(:context) { { id: SecureRandom.uuid, name: "Foo Barovich" } }
  let(:aggregate_type) { "user" }
  let(:queue) { "test-queue" }
  let(:event_type) { "created" }
  let(:payload_schema) { JSON.load_file("#{Dir.pwd}/spec/fixtures/event_schema.json") }
  let(:event_builder_class) { "TransactionalOutbox::Event::Builder" }
  let(:payload_block) { ->(context) { { id: context[:id], name: context[:name] } } }
  let(:correct_event_data) do
    {
      queue:,
      queue_extra_parameters: nil,
      aggregate_type:,
      event_type:,
      headers: {},
      payload: { id: context[:id], name: context[:name] }
    }
  end

  let(:short_payload_block) { ->(context) { { id: context[:id] } } }
  let(:short_correct_event_data) do
    { queue:, queue_extra_parameters: nil, aggregate_type:, event_type:, headers: {}, payload: { id: context[:id] } }
  end

  describe "#create!" do
    subject { event_class.new.create!(context) }

    include_context "event creation common cases"
  end

  describe "#bulk_create!" do
    subject { event_class.new.bulk_create!(contexts) }

    let(:contexts) { [context] }

    include_context "event creation common cases"
  end
end
