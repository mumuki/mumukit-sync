module Mumukit::Sync::Inflator
  class Choice < Exercise
    def inflate_exercise!(exercise_h, language_name, guide_h)
      return unless language_name == 'text'
      return unless exercise_h[:editor] == editor_type
      return if exercise_h[:test]

      exercise_h[:test] = choices_to_test(exercise_h[:choices])
    end
  end
end
