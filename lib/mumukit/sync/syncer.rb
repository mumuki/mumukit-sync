## An import and export pipeline for generic resources.
##
## A resource - that is, something that can be imported or exported - must implement the following methods:
##
## * #sync_key: returns a kind-id pair created using `Mumukit::Sync.key`, used to locate resources within a store
## * #to_resource_h: returns a canonical hash representation of the resource. Only required by `Mumukit::Sync#export!`
## * #from_resource_h!: populates the resource with its canonical hash representation
## * #save!: saves the resource. Only required by `Mumukit::Sync#import_and_save!` and `Mumukit::Sync#import_all!`
## * .locate_resource(resource_id): finds or initializes the resource given its resource id. Only required by `Mumukit::Sync#import_all!`

module Mumukit::Sync
  class Syncer
    def initialize(store, inflators = [])
      @store = store
      @inflators = inflators
    end

    def sync_keys_matching(id_regex = nil)
      id_regex ||= /.*/
      @store.sync_keys.select { |key| id_regex.matches? key.id }
    end

    def import_all!(id_regex = nil, resource_classifier = proc { |kind| kind.to_s.classify.constantize })
      sync_keys_matching(id_regex).each do |key|
        puts "Importing #{key.kind} #{key.id}"
        begin
          import_and_save! resource_classifier.call(key.kind).locate_resource(key.id)
        rescue => e
          puts "Ignoring #{key.id} because of import error #{e}"
        end
      end
    end

    def import!(resource)
      resource_h = @store.read_resource(resource.sync_key)
      @inflators.each { |it| it.inflate! resource_h }
      resource.from_resource_h!(resource_h)
    end

    def import_and_save!(resource)
      import! resource
      resource.save!
    end

    def export!(resource)
      resource_h = resource.to_resource_h
      @destination.write_resource!(resource.sync_key, resource_h)
    end
  end
end
