class Mumukit::Sync::Store::Github
  class ExerciseBuilder < OpenStruct
    def locale
      meta['locale']
    end

    def build
      build_metadata.merge(build_simple_fields).compact
    end

    def build_simple_fields
      schema.simple_fields.map { |field| [field.reverse_name, self.send(field.reverse_name)] }.to_h
    end

    def build_metadata
      schema.metadata_fields.map { |field| [field.reverse_name, meta[field.name.to_s]] }.to_h
    end
  end
end
