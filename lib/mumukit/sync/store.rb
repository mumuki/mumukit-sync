module Mumukit::Sync
  module Store
    def self.non_discoverable!
      raise Mumukit::Sync::SyncError, 'Non-discoverable store'
    end

    def self.read_only!
      raise Mumukit::Sync::SyncError, 'Read-only store'
    end
  end
end


require_relative './store/base'
require_relative './store/null'
require_relative './store/github'
require_relative './store/json'
require_relative './store/with_wrapped_language'
require_relative './store/with_filtered_id'
