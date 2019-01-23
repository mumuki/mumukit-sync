module Mumukit::Sync::Store
  class Json < Mumukit::Sync::Store::Base
    def initialize(json)
      @json = json
    end

    def sync_keys
      Mumukit::Sync::Store.non_discoverable!
    end

    def do_read(_sync_key)
      @json
    end

    def write_resource!(*)
      Mumukit::Sync::Store.read_only!
    end
  end
end
