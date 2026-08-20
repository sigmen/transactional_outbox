# frozen_string_literal: true

def gen_messages(topic, count)
  repo = TransactionalOutbox::Database.new

  count.times do
    repo.insert_events({ topic:, payload: {} })
  end
end
