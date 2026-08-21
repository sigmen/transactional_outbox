# frozen_string_literal: true

def clear_database_adapters_container
  clear_adapters_container(
    TransactionalOutbox::Database::Adapters, TransactionalOutbox::BASE_DATABASE_ADAPTERS
  )
end

def clear_producer_adapters_container
  clear_adapters_container(
    TransactionalOutbox::Producer::Adapters, TransactionalOutbox::BASE_PRODUCER_ADAPTERS
  )
end

def clear_adapters_container(adapters_manager_class, legal_adapters)
  container = adapters_manager_class.instance_variable_get(:@container).instance_variable_get(:@_container)

  (container.keys - legal_adapters).each { |key| container.delete(key) }
end
