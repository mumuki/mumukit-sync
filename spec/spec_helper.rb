require "bundler/setup"
require "mumukit/sync"
require "mumukit/core/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end


Mumukit::Sync::Store::Github.configure do |config|
  config.guide_schema = Mumukit::Sync::Store::Github::Schema::Guide
  config.exercise_schema = Mumukit::Sync::Store::Github::Schema::Exercise
end
