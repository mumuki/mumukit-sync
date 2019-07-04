class Mumukit::Sync::Store::Github
  ## Schema definition explanation
  #
  #  * name: the name of the field
  #  * kind: the type of the field: metadata, special, file or transient.
  #     * metadata fields are those that are small and fit into the metadata.yml when exported to git
  #     * special fields are those are essentials and not part of any file, like the id or name when exported to git
  #     * transient fields are not exported to git
  #     * file fields are large fields that are exported to git within their own file.
  #  * reverse: the name of the field in the model. By default, it is assumed to be the same of name, but
  #    can be overridden with this option
  #  * default: the default value of the field
  #  * extension: the file extension. It only applies to file kinds. It can be a plain extension or one of the following
  #    special extensions:
  #      * test: the extension of the test framework
  #      * code: the normal extension for the language
  #
  module Schema
    def defaults
      fields.map { |it| [it.reverse_name, it.default] }.to_h.compact
    end

    def metadata_fields
      fields.select { |it| it.kind == :metadata }
    end

    def simple_fields
      fields.select { |it| [:special, :file].include? it.kind }
    end

    def file_fields
      fields.select { |it| it.kind == :file }
    end

    def file_patterns
      file_fields.map(&:get_file_pattern) + fixed_file_patterns
    end

    def fixed_file_patterns
      []
    end

    def fields
      @field ||= fields_schema.map { |it| new_field(it) }
    end

    def slice(json)
      json.slice(*fields.map(&:reverse_name))
    end

    def yaml_hash
      struct to: proc(&:to_yaml),
             from: proc { |path| YAML.load_file(path) }
    end

    def yaml_list(key)
      struct to: proc { |it| {key => it.map(&:stringify_keys)}.to_yaml },
             from: proc { |path| YAML.load_file(path).try { |it| it[key] } }
    end

    def name
      with { |it| it&.dig(:name) }
    end

    def with(&block)
      struct to: block, from: proc { |it| File.read(it) }
    end

    private

    def new_field(it)
      Field.new(it)
    end

    class Field < OpenStruct
      def reverse_name
        reverse || name
      end

      def safe_transform
        transform || struct(to: proc { |it| it }, from: proc { |it| File.read(it) })
      end

      ## Writing fields to Github
      def get_file_pattern
        get_file_name extension: '*', test_extension: '*'
      end

      def get_file_name(language)
        "#{name}.#{get_file_extension(language)}"
      end

      def get_field_value(document)
        safe_transform.to.call document[reverse_name]
      end

      def field_value_present?(document)
        document[reverse_name].present?
      end

      def get_file_extension(language)
        case extension
        when :code then
          language[:extension]
        when :test then
          language[:test_extension]
        else
          extension
        end
      end

      ## Reading fields from Github

      def find_file_name(description, root)
        files = Dir.glob("#{root}/#{name}.*")
        if files.length == 1
          files[0]
        elsif files.empty? && required
          raise Mumukit::Sync::SyncError, "Missing #{description} #{name} file"
        else
          nil
        end
      end

      def read_field_file(description, root)
        find_file_name(description, root).try { |it| safe_transform.from.call it }
      end

    end
  end
end

require_relative './schema/exercise'
require_relative './schema/guide'
