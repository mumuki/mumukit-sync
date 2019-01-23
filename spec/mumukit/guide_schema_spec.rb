require 'spec_helper'

describe Mumukit::Sync::Store::Github::Schema::Guide do
  it do
    expect(Mumukit::Sync::Store::Github::Schema::Guide.file_patterns).to match_array %w(
      LICENSE.txt
      README.md
      COPYRIGHT.txt
      meta.yml
      expectations.yml
      *_*/*
      AUTHORS.txt
      COLLABORATORS.txt
      description.md
      corollary.md
      sources.md
      learn_more.md
      extra.*)
  end
end
