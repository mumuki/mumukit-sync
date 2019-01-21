class Mumukit::Sync::Store::Github
  class GuideReader
    include Mumukit::Sync::Store::Github::WithFileReading

    attr_reader :dir

    def initialize(dir, repo)
      @dir = File.expand_path(dir)
      @slug = repo.to_s
    end

    def read_guide!
      builder = GuideBuilder.new(@slug)

      read_guide_meta! builder
      Mumukit::Sync::Store::Github::Schema::Guide.file_fields.each do |it|
        value = it.read_field_file(dir)
        builder[it.reverse_name] = value
      end
      read_exercises! builder

      builder.build
    end

    def read_meta!(description, dir)
      meta = read_yaml_file(File.join(dir, 'meta.yml'))
      raise Mumukit::Sync::SyncError, "Missing #{description} meta.yml" unless meta

      meta
    rescue Psych::SyntaxError
      raise Mumukit::Sync::SyncError, "Bad #{description} metadata syntax"
    end

    def read_guide_meta!(builder)
      meta = read_meta! 'guide', dir

      builder.language = { name: meta['language'] }
      builder.locale = meta['locale']

      read! 'name', builder, meta
      read! 'id_format', builder, meta
      read! 'type', builder, meta
      read! 'beta', builder, meta
      read! 'teacher_info', builder, meta

      read_legacy! builder, meta

      builder.order = Mumukit::Sync::Store::Github::Ordering.from meta['order']
    end

    def read_legacy!(builder, meta)
      builder.id_format ||= meta['original_id_format']
      builder.type ||= meta['learning'] ? 'learning' : 'practice'
    end

    def read!(key, builder, meta)
      builder[key] = meta[key]
    end

    def read_exercises!(builder)
      read_exercises do |exercise_builder|
        builder.add_exercise exercise_builder.build
      end
    end

    def read_exercises
      each_exercise_file do |root, position, id, name|
        builder = ExerciseBuilder.new

        meta = read_meta! "exercise #{name}", root
        meta['language'] &&= { name: meta['language'] }

        builder.meta = meta
        builder.id = id
        builder.name = meta['name'] || name

        Mumukit::Sync::Store::Github::Schema::Exercise.file_fields.each do |it|
          value = it.read_field_file(root)
          builder[it.reverse_name] = value
        end
        yield builder
      end
    end

    private

    def each_exercise_file
      Dir.glob("#{@dir}/**").sort.each_with_index do |file, index|
        basename = File.basename(file)
        match = /(\d*)_(.+)/.match basename
        next unless match
        yield file, index + 1, match[1].to_i, match[2]
      end
    end
  end
end
