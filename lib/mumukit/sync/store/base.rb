class Mumukit::Sync::Store::Base
  def read_resource(sync_key)
    post_transform sync_key.kind, pre_transform(sync_key.kind, do_read(sync_key)).deep_symbolize_keys
  end

  private

  # We are assuming rails-like models, that can be whitelisted,
  # and that resource-hashes resemble the model structure.
  # The store must ensure that only valid hashes are read
  def pre_transform(key, json)
    Mumukit::Sync.constantize(key).whitelist_attributes(json, relations: true)
  end

  def post_transform(_key, json)
    json
  end
end
