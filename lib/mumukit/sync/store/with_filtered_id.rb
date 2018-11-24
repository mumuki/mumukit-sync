module Mumukit::Sync::Store::WithFilteredId
  def transform_before_symbolize(key, json)
    super.tap { |it| it.indifferent_delete(:id) }
  end
end
