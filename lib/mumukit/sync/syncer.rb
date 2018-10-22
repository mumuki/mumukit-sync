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
      @resource_classifier ||= proc { |kind| Mumukit::Sync.constantize(kind) }
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
      locate(key_for(*args)).tap { |it| import! it }
    end

    def import!(resource)
      resource_h = @store.read_resource(resource.sync_key)
      @inflators.each { |it| it.inflate! resource.sync_key, resource_h }
      resource.import_from_resource_h!(resource_h)
    end

    def locate_and_export!(*args)
      locate(key_for(*args)).tap { |it| export! it }
    end

    def export!(resource)
      resource_h = resource.to_resource_h
      @store.write_resource!(resource.sync_key, resource_h)
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

module Mumukit::Sync::Inflator
  class SingleChoice
    def inflate!(key, resource_h)
      return unless key.kind == :guide
      return unless resource_h[:language][:name] == 'text'
      return unless resource_h[:editor] == 'single_choice'
      resource_h[:test] = single_choices_to_test
    end

    def single_choices_to_test
      choice = choices.find { |choice| choice['checked'] }
      {'equal' => choice['value']}.to_yaml
    end
  end

  class MultipleChoice
    def inflate!(key, resource_h)
      return unless key.kind == :guide
      return unless resource_h[:language][:name] == 'text'
      return unless resource_h[:editor] == 'multiple_choice'
      resource_h[:test] = multiple_choices_to_test
    end

    def multiple_choices_to_test
      value = choices.each_with_index
                .map { |choice, index| choice.merge('index' => index.to_s) }
                .select { |choice| choice['checked'] }
                .map { |choice| choice['index'] }.join(':')
      {'equal' => value}.to_yaml
    end
  end
end
