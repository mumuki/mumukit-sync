module Mumukit::Sync::Inflator
  class GobstonesKidsBoards < Exercise
    def inflate_exercise!(exercise_h, language_name, guide_h)
      return unless language_name == 'gobstones'
      return unless exercise_h[:layout] == 'input_kids'
      return unless exercise_h[:test]

      spec = YAML.load(exercise_h[:test])
      examples = spec&.dig('examples')
      with_head = spec&.dig('check_head_position')

      return unless examples&.any?

      exercise_h[:initial_state] = build_boards :initial_board, examples
      exercise_h[:final_state] = build_boards :final_board, examples, with_head
    end

    def to_gs_board(board, with_head)
      "<gs-board#{with_head ? "" : " without-header"}> #{board} </gs-board>"
    end

    def build_boards(method_name, examples, *args)
      examples.map { |example| send method_name, example, *args }.join("\n")
    end

    def initial_board(example)
      to_gs_board(example['initial_board'], true)
    end

    def final_board(example, with_head)
      final_board = example['final_board']
      if final_board.blank?
        self.class.boom_board
      else
        to_gs_board(final_board, with_head)
      end
    end

    def self.boom_board
      "<img src='https://user-images.githubusercontent.com/1631752/37945593-54b482c0-3157-11e8-9f32-bd25d7bf901b.png'>"
    end
  end
end
