module Mumukit::Sync::Store::Github::Schema::Guide
  extend Mumukit::Sync::Store::Github::Schema

  def self.fields_schema
    [
      {name: :exercises},
      {name: :id},
      {name: :slug},

      {name: :name},
      {name: :locale},
      {name: :type},
      {name: :teacher_info},
      {name: :language},
      {name: :order},
      {name: :beta},
      {name: :id_format, default: '%05d'},

      {name: :expectations},
      {name: :description},
      {name: :corollary},
      {name: :extra},
      {name: :AUTHORS, reverse: :authors},
      {name: :COLLABORATORS, reverse: :collaborators},
      {name: :private}
    ]
  end
end
