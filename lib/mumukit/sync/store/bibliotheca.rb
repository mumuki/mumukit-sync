module Mumukit::Sync::Store
  class Bibliotheca
    def initialize(bibliotheca_bridge)
      @bibliotheca_bridge = bibliotheca_bridge
    end

    def sync_keys
      %w(guide topic book).flat_map do |kind|
        @bibliotheca_bridge
          .send(kind.to_s.pluralize)
          .map { |it| Mumukit::Sync.key kind, it['slug']  }
      end
    end

    def read_resource(sync_key)
      @bibliotheca_bridge.send(sync_key.kind, sync_key.id)
    end

    def write_resource!(*)
      raise 'Read-only store'
    end
  end
end
