module Mumukit::Sync::Store::WithFilteredId
  def pre_transform(key, json)
    super.tap { |it| it.indifferent_delete(:id) }
  end
end
