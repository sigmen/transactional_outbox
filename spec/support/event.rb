# frozen_string_literal: true

def define_event(payload_schema, aggregate_type, event_type, topic_name, message_builder_class, payload_block)
  Class.new(TransactionalOutbox::Event) do
    schema payload_schema
    aggregate_type aggregate_type
    event_type event_type
    topic topic_name
    message_builder message_builder_class

    context do
      required(:id).filled(:string)
      required(:name).filled(:string)
    end

    payload(&payload_block)
  end
end
