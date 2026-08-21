# frozen_string_literal: true

def gen_events(topic, count)
  return if count == 0

  repo = TransactionalOutbox::Database.new
  events = count.times.map { { topic:, payload: {} } }

  repo.insert_events(events)
end
