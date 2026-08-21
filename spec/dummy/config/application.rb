require "rails"
require "kafka"
require "sequel"

module Dummy
  class Application < Rails::Application
    config.root = File.expand_path("..", __dir__)
    config.logger = Logger.new($stdout)
    config.eager_load = false
  end
end
