class Mumukit::Sync::Store::Github
  class ExerciseBuilder < OpenStruct
    def locale
      meta['locale']
    end

    def build
      build_metadata.merge(build_simple_fields).compact
    end

    def build_simple_fields
      Mumukit::Sync::Store::Github::Schema.build_fields_h(Mumukit::Sync::Store::Github::Schema::Exercise.simple_fields) { |field| self.send(field.reverse_name) }
    end

    def build_metadata
      Mumukit::Sync::Store::Github::Schema.build_fields_h(Mumukit::Sync::Store::Github::Schema::Exercise.metadata_fields) { |field| meta[field.name.to_s] }
    end
  end
end
