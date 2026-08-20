# frozen_string_literal: true

def gen_messages(topic, count)
  repo = TransactionalOutbox::Repositories::OutboxEvent.new

  count.times do
    repo.insert({ topic:, payload: {} })
  end
end
