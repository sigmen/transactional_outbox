# frozen_string_literal: true

require "logger"

TransactionalOutbox.configure do |config|
  config.logger = Logger.new($stdout)
  config.test_environment = true
  config.batch_size = 10
end
