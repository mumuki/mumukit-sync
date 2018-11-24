class Mumukit::Sync::Store::Base
  def read_resource(sync_key)
    transform_after_symbolize sync_key.kind, transform_before_symbolize(sync_key.kind, do_read(sync_key)).deep_symbolize_keys
  end

  private

  # We are assuming rails-like models, that can be whitelisted,
  # and that resource-hashes resemble the model structure.
  # The store must ensure that only valid hashes are read
  def transform_before_symbolize(key, json)
    key.as_module.whitelist_attributes(json, relations: true)
  end

  def transform_after_symbolize(_key, json)
    json
  end
end
