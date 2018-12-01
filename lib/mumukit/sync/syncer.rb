## An import and export pipeline for generic resources.
##
## A resource - that is, something that can be imported or exported - must implement the following methods:
##
## * #sync_key: returns a kind-id pair created using `Mumukit::Sync.key`, used to locate resources within a store
## * #to_resource_h: returns a canonical hash representation of the resource. Only required by `Mumukit::Sync#export!`
## * #import_from_resource_h!: populates and saves the resource with its canonical hash representation
## * .locate_resource(resource_id): finds or initializes the resource given its resource id. Only required by `Mumukit::Sync#import_all!`

module Mumukit::Sync
  class Syncer
    def initialize(store, inflators = [], resource_classifier = nil)
      @store = store
      @inflators = inflators
      @resource_classifier ||= proc { |kind| kind.as_module }
    end

    def sync_keys_matching(id_regex = nil)
      id_regex ||= /.*/
      @store.sync_keys.select { |key| id_regex.matches? key.id }
    end

    def import_all!(id_regex = nil)
      sync_keys_matching(id_regex).each do |key|
        puts "Importing #{key.kind} #{key.id}"
        begin
          locate_and_import! key
        rescue => e
          puts "Ignoring #{key.id} because of import error #{e}"
        end
      end
    end

    def locate_and_import!(*args)
      sync_key = key_for(*args)
      locate(sync_key).tap { |it| import! sync_key, it }
    end

    def import!(sync_key = nil, resource)
      sync_key ||= resource.sync_key
      resource_h = @store.read_resource(sync_key)
      Mumukit::Sync::Inflator.inflate_with! sync_key, resource_h, @inflators
      resource.import_from_resource_h!(resource_h)
    end

    def locate_and_export!(*args)
      sync_key = key_for(*args)
      locate(sync_key).tap { |it| export! sync_key, it }
    end

    def export!(sync_key = nil, resource)
      sync_key ||= resource.sync_key
      resource_h = resource.to_resource_h
      @store.write_resource!(sync_key, resource_h)
    end

    private

    def locate(key)
      @resource_classifier.call(key.kind).locate_resource(key.id)
    end

    def key_for(*args)
      args.size == 1 ? args.first : Mumukit::Sync.key(*args)
    end
  end
end
