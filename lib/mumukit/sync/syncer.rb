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
  class Exercise
    def inflate!(key, resource_h)
      return unless key.kind == :guide
      resource_h[:exercises]&.each do |it|
        language = it.dig(:language, :name) || resource_h.dig(:language, :name)
        inflate_exercise! it, language, resource_h
      end
    end
  end

  class Choice < Exercise
    def inflate_exercise!(exercise_h, language_name, guide_h)
      return unless language_name == 'text'
      return unless exercise_h[:editor] == editor_type
      return if exercise_h[:test]

      exercise_h[:test] = choices_to_test(exercise_h[:choices])
    end
  end

  class SingleChoice < Choice
    def editor_type
      'single_choice'
    end

    def choices_to_test(choices)
      choice = choices.find { |choice| choice[:checked] }
      {'equal' => choice[:value]}.to_yaml
    end
  end

  class MultipleChoice < Choice
    def editor_type
      'multiple_choice'
    end

    def choices_to_test(choices)
      value = choices.each_with_index
                .map { |choice, index| choice.merge(:index => index.to_s) }
                .select { |choice| choice[:checked] }
                .map { |choice| choice[:index] }.join(':')
      {'equal' => value}.to_yaml
    end
  end

  ## TODO REMOVE
  class GobstonesKidsBoards < Exercise
    def inflate_exercise!(exercise_h, language_name, guide_h)
      return unless language_name == 'gobstones'
      return unless exercise_h[:layout] == 'input_kids'
      return unless exercise_h[:test]

      spec = YAML.load(exercise_h[:test])
      example = spec&.dig('examples')&.first
      with_head = spec&.dig('check_head_position')

      return unless example

      exercise_h[:initial_state] = initial_board example
      exercise_h[:final_state] = final_board example, with_head
    end

    def to_gs_board(board, with_head)
      "<gs-board#{with_head ? "" : " without-header"}> #{board} </gs-board>" if board
    end


    def initial_board(example)
      to_gs_board(example['initial_board'], true)
    end

    def final_board(example, with_head)
      to_gs_board(example['final_board'], with_head) || self.class.boom_board
    end

    def self.boom_board
      "<img src='https://user-images.githubusercontent.com/1631752/37945593-54b482c0-3157-11e8-9f32-bd25d7bf901b.png'>"
    end
  end

end
