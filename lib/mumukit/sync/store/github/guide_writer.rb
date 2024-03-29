class Mumukit::Sync::Store::Github
  class GuideWriter
    include Mumukit::Sync::Store::Github::WithSchema

    attr_accessor :dir

    def initialize(dir)
      @dir = dir
    end

    def write_file_fields!(base_path, schema, element, language)
      schema.file_fields.each do |it|
        file_name = it.get_file_name(language)
        write_file! base_path, file_name, it.get_field_value(element) if it.field_value_present?(element)
      end
    end

    def write_metadata_fields!(base_path, schema, e)
      metadata = schema.metadata_fields.map do |field|
        [field.name.to_s, field.get_field_value(e)]
      end.to_h.compact.merge('name' => e[:name]).to_yaml
      write_file! base_path, 'meta.yml', metadata
    end

    def write_guide!(guide)
      guide[:exercises].each do |e|
        write_exercise! guide, e
      end
      write_licenses!(guide)

      write_metadata_fields! dir, guide_schema, guide
      write_file_fields! dir, guide_schema, guide, guide[:language]
    end

    def format_id(guide, exercise)
      guide[:id_format] % exercise[:id]
    end

    def write_exercise!(guide, e)
      dirname = File.join dir, to_fs_friendly_name("#{format_id(guide, e)}_#{e[:name]}")

      FileUtils.mkdir_p dirname

      write_metadata_fields! dirname, exercise_schema, e
      write_file_fields! dirname, exercise_schema, e, (e[:language] || guide[:language])
    end

    def write_licenses!(guide)
      write_file! dir, 'COPYRIGHT.txt', copyright_content(guide)
      write_file! dir, 'README.md', readme_content(guide)
      copy_file! 'LICENSE.txt'
    end

    private

    def default_filename(guide)
      "default.#{guide[:language][:extension]}"
    end

    def write_file!(dirname, name, content)
      File.write(File.join(dirname, name), content)
    end

    def copyright_content(guide)
      @guide_authors = guide[:authors]
      @guide_repo_url = "https://github.com/#{guide[:slug]}"
      ERB.new(read_file 'COPYRIGHT.txt.erb').result binding
    end

    def readme_content(guide)
      @copyright = copyright_content guide
      ERB.new(read_file 'README.md.erb').result binding
    end

    def copy_file!(name)
      FileUtils.cp licenses_dir(name), dir
    end

    def read_file(name)
      File.read licenses_dir(name)
    end

    def licenses_dir(name)
      File.join __dir__, 'licenses', name
    end

    def to_fs_friendly_name(dirname)
      dirname.gsub(/[\x00\/\\:\*\.\?\"<>\|]/, '_')
    end
  end
end
