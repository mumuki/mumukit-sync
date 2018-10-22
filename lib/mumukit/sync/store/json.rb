module Mumukit::Sync::Store
  class Json
    def initialize(json)
      @json = json
    end

    def sync_keys
      raise 'Non-discoverable store'
    end

    def read_resource(sync_key)
      post_transform sync_key.kind, pre_transform(sync_key.kind, @json).deep_symbolize_keys
    end

    def write_resource!(*)
      raise 'Read-only store'
    end

    def pre_transform(kind, json)
      json
    end

    def post_transform(kind, json)
      json
    end
  end
end
