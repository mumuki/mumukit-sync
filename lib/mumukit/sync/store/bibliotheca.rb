module Mumukit::Sync::Store

  ## This Store enables importing content
  ## from Bibliotheca API
  class Bibliotheca < Mumukit::Sync::Store::Base
    include Mumukit::Sync::Store::WithWrappedLanguage
    include Mumukit::Sync::Store::WithFilteredId

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

    def do_read(sync_key)
      @bibliotheca_bridge.send(sync_key.kind, sync_key.id)
    end

    def write_resource!(*)
      raise 'Read-only store'
    end
  end
end
