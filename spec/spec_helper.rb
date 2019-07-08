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

# Dummy definition that is loosly based on actual mumuki's domain,
# but is a simplification to allow testing
# This list does not need to keep up to date
module DummyGithubExerciseSchema
  extend Mumukit::Sync::Store::Github::Schema

  def self.fields_schema
    [
      {name: :id, kind: :special},
      {name: :name, kind: :special},
      {name: :tags, kind: :metadata, reverse: :tag_list, transform: with { |it| it.to_a }},
      {name: :layout, kind: :metadata},
      {name: :editor, kind: :metadata},
      {name: :type, kind: :metadata},
      {name: :language, kind: :metadata, transform: name },
      {name: :expectations,     kind: :file, extension: 'yml', transform: yaml_list('expectations')},
      {name: :test, kind: :file, extension: :test},
      {name: :extra, kind: :file, extension: :code},
      {name: :description, kind: :file, extension: 'md', required: true},
      {name: :free_form_editor_source, kind: :file, extension: 'html'}
    ]
  end
end


module DummyGithubGuideSchema
  extend Mumukit::Sync::Store::Github::Schema

  def self.fields_schema
    [
      {name: :exercises, kind: :special},
      {name: :id, kind: :special},
      {name: :slug, kind: :special},
      {name: :name, kind: :metadata},
      {name: :locale, kind: :metadata},
      {name: :beta, kind: :metadata},
      {name: :language, kind: :metadata, transform: name },
      {name: :id_format, kind: :metadata},
      {name: :order, kind: :metadata, transform: with { |it| it.map { |e| e[:id] } }, reverse: :exercises},
      {name: :expectations, kind: :file, extension: 'yml', transform: yaml_list('expectations')},
      {name: :description, kind: :file, extension: 'md', required: true},
      {name: :AUTHORS, kind: :file, extension: 'txt', reverse: :authors},
      {name: :COLLABORATORS, kind: :file, extension: 'txt', reverse: :collaborators}
    ]
  end

  def self.fixed_file_patterns
    %w(LICENSE.txt README.md COPYRIGHT.txt meta.yml *_*/*)
  end
end



Mumukit::Sync::Store::Github.configure do |config|
  config.guide_schema = DummyGithubGuideSchema
  config.exercise_schema = DummyGithubExerciseSchema
end
