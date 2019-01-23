class Mumukit::Sync::Store::Github
  class GuideBuilder < OpenStruct
    attr_writer :exercises

    def initialize(slug)
      super()
      self.slug = slug
    end

    def exercises
      @exercises ||= []
    end

    def build
      build_json.compact
    end

    def add_exercise(exercise)
      self.exercises << exercise
    end

    private

    def build_json
      raise Mumukit::Sync::SyncError, "Missing guide language" if language[:name].blank?

      {name: name,
       description: description,
       corollary: corollary,
       language: language,
       locale: locale,
       type: type,
       extra: extra,
       beta: beta,
       authors: authors,
       collaborators: collaborators,
       teacher_info: teacher_info,
       id_format: id_format,
       slug: slug,
       expectations: expectations.to_a,
       exercises: exercises.sort_by { |e| order.position_for(e[:id]) }}
    end

  end
end
