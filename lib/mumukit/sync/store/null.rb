module Mumukit::Sync::Store
  class NullStore
    def write_resource!(*)
    end

    def read_resource(key)
      raise Mumukit::Sync::SyncError, "Non-readable store"
    end
  end
end
