module Mumukit::Sync::Store::WithIdFiltering
  def pre_transform(key, json)
    super.tap { |it| it.indifferent_delete(:id) }
  end
end
