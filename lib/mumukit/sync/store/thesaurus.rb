module Mumukit::Sync::Store
  class Thesaurus < Mumukit::Sync::Store::Base
    def initialize(thesaurus_bridge)
      @thesaurus_bridge = thesaurus_bridge
    end

    def sync_keys
      @thesaurus_bridge.runners.map { |it| Mumukit::Sync.key(:language, it) }
    end

    def do_read(sync_key)
      return unless sync_key.kind == :language
      Mumukit::Bridge::Runner.new(sync_key.id).importable_info
    end

    def write_resource!(*)
      raise 'Read-only store'
    end
  end
end
