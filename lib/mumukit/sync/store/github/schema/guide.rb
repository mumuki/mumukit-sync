module Mumukit::Sync::Store::Github::Schema::Guide
  extend Mumukit::Sync::Store::Github::Schema

  def self.fields_schema
    [
      {name: :exercises, kind: :special},
      {name: :id, kind: :special},
      {name: :slug, kind: :special},

      {name: :name, kind: :metadata},
      {name: :locale, kind: :metadata},
      {name: :type, kind: :metadata},
      {name: :beta, kind: :metadata},
      {name: :teacher_info, kind: :metadata},
      {name: :language, kind: :metadata, transform: name },
      {name: :id_format, kind: :metadata},
      {name: :order, kind: :metadata, transform: with { |it| it.map { |e| e[:id] } }, reverse: :exercises},
      {name: :private, kind: :metadata},
      {name: :expectations},

      {name: :description, kind: :file, extension: 'md', required: true},
      {name: :corollary, kind: :file, extension: 'md'},
      {name: :extra, kind: :file, extension: :code},
      {name: :AUTHORS, kind: :file, extension: 'txt', reverse: :authors},
      {name: :COLLABORATORS, kind: :file, extension: 'txt', reverse: :collaborators}
    ]
  end
end
