# frozen_string_literal: true

require_relative "lib/transactional_outbox/version"

Gem::Specification.new do |spec|
  spec.name = "transactional_outbox"
  spec.version = TransactionalOutbox::VERSION
  spec.authors = ["Roman Kakorin"]
  spec.email = ["romchky1@gmail.com"]

  spec.summary = "Implementation of transactional outbox pattern."
  spec.description = "Implementation of transactional outbox pattern."
  spec.homepage = "https://github.com/sigmen/transactional_outbox"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sigmen/transactional_outbox"
  spec.metadata["changelog_uri"] = "https://github.com/sigmen/transactional_outbox/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency "dry-configurable"
  spec.add_dependency "json-schema"
  spec.add_dependency "oj"
  spec.add_dependency "rake", "~> 13.0"
  spec.add_dependency "dry-container", "~> 0.11"
  spec.add_dependency "dry-monitor"
  spec.add_dependency "dry-validation", "~> 1.11"

  spec.add_development_dependency "ruby-kafka"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rails", "~> 8.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "sequel"
end
