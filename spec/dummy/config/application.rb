require "rails"
require "kafka"

module Dummy
  class Application < Rails::Application
    config.root = File.expand_path("..", __dir__)
    config.logger = Logger.new($stdout)
    config.eager_load = false
    config.autoload_paths << root.join("app/outbox")
  end
end
