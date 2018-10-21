class Mumukit::Sync::Store::Github
  class ExerciseBuilder < OpenStruct
    def locale
      meta['locale']
    end

    def build
      build_metadata.merge(build_simple_fields).compact
    end

    def build_simple_fields
      Mumukit::Sync::Store::Github::Schema::Exercise.simple_fields.map { |field| [field.reverse_name, self.send(field.name)] }.to_h
    end

    def build_metadata
      Mumukit::Sync::Store::Github::Schema::Exercise.metadata_fields.map { |field| [field.reverse_name, meta[field.name.to_s]] }.to_h
    end
  end
end
