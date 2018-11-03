module Mumukit::Sync::Inflator
  class SingleChoice < Choice
    def editor_type
      'single_choice'
    end

    def choices_to_test(choices)
      choice = choices.find { |choice| choice[:checked] }
      {'equal' => choice[:value]}.to_yaml
    end
  end
end
