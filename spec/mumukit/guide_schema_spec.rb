require 'spec_helper'

describe Mumukit::Sync::Store::Github::Schema do
  it do
    expect(Mumukit::Sync::Store::Github.config.guide_schema.file_patterns).to match_array %w(
      LICENSE.txt
      README.md
      COPYRIGHT.txt
      meta.yml
      expectations.yml
      *_*/*
      AUTHORS.txt
      COLLABORATORS.txt
      description.md)
  end
end
