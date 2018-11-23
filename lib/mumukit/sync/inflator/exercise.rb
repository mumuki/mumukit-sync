module Mumukit::Sync::Inflator
  class Exercise
    def inflate!(key, resource_h)
      return unless key.kind.like? :guide
      resource_h[:exercises]&.each do |it|
        language = it.dig(:language, :name) || resource_h.dig(:language, :name)
        inflate_exercise! it, language, resource_h
      end
    end
  end
end
