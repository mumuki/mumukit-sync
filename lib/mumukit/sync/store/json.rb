module Mumukit::Sync::Store
  class Json < Mumukit::Sync::Store::Base
    def initialize(json)
      @json = json
    end

    def sync_keys
      raise 'Non-discoverable store'
    end

    def do_read(_sync_key)
      @json
    end

    def write_resource!(*)
      raise 'Read-only store'
    end
  end
end
