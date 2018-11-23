require 'git'
require 'octokit'


require "mumukit/sync/version"

module Mumukit
  module Sync

    # Creates a sync key, composed of a `kind` and `id`
    #
    # kind: string|symbol|class
    # id: object
    #
    # Warning: in order to test the `kind`, always use the `like?` message
    def self.key(kind, id)
      struct kind: kind, id: id
    end

    def self.constantize(kind)
      classify(kind).constantize
    end

    def self.classify(kind)
      kind.to_s.classify
    end
  end
end

require 'mumukit/core'

require_relative './sync/syncer'
require_relative './sync/store'
require_relative './sync/inflator'
