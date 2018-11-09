class Mumukit::Sync::Store::Base
  def read_resource(sync_key)
    post_transform sync_key.kind, pre_transform(sync_key.kind, do_read(sync_key)).deep_symbolize_keys
  end

  private

  def pre_transform(key, json)
    Mumukit::Sync.constantize(key).whitelist_attributes(json, relations: true)
  end

  def post_transform(_key, json)
    json
  end
end
