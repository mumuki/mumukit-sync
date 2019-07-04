class Mumukit::Sync::Store::Github
  class ExerciseBuilder < OpenStruct
    include Mumukit::Sync::Store::Github::WithSchema

    def locale
      meta['locale']
    end

    def build
      build_metadata.merge(build_simple_fields).compact
    end

    def build_simple_fields
      build_fields_h(exercise_schema.simple_fields) { |field| self.send(field.reverse_name) }
    end

    def build_metadata
      build_fields_h(exercise_schema.metadata_fields) { |field| meta[field.name.to_s] }
    end
  end
end
