module Mumukit::Sync::Store::WithWrappedLanguage
  def post_transform(key, json)
    if key == :guide
      guide = json.dup
      wrap_language! guide
      guide[:exercises].each { |exercise| wrap_language! exercise }
      guide
    else
      json
    end
  end

  def wrap_language!(hash)
    hash[:language] = { name: hash[:language] } if hash[:language]
  end
end
