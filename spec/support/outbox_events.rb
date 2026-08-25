# frozen_string_literal: true

def gen_events(queue, count)
  return if count == 0

  repo = TransactionalOutbox::Database.new
  events = count.times.map { { id: SecureRandom.uuid, queue:, payload: {} } }

  repo.insert_events(events)
end
