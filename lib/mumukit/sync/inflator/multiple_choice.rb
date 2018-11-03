module Mumukit::Sync::Inflator
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
end
