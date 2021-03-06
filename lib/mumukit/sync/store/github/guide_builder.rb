class Mumukit::Sync::Store::Github
  class GuideBuilder < OpenStruct
    include Mumukit::Sync::Store::Github::WithSchema

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

    def locale
      meta['locale']
    end

    def language
      meta['language']
    end

    private

    def build_json
      raise Mumukit::Sync::SyncError, "Missing guide language" if language.blank?
      file = build_fields_h(guide_schema.file_fields) { |field| self[field.reverse_name] }
      metadata = build_fields_h(guide_schema.metadata_fields) { |field| self.meta[field.name.to_s] }
      file.merge(metadata).merge(
        expectations: expectations.to_a,
        slug: slug,
        exercises: exercises.sort_by { |e| order.position_for(e[:id]) }).compact
    end
  end
end
