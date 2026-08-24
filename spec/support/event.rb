# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
def define_event(payload_schema, aggregate_type, event_type, queue_name, event_builder_class, payload_block)
  Class.new(TransactionalOutbox::Event) do
    schema payload_schema
    aggregate_type aggregate_type
    event_type event_type
    queue queue_name
    event_builder event_builder_class

    context do
      required(:id).filled(:string)
      required(:name).filled(:string)
    end

    prepare_payload(&payload_block)
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/ParameterLists
