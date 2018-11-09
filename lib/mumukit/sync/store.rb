require 'mumukit/bridge'

module Mumukit::Sync
  module Store
  end
end


require_relative './store/base'
require_relative './store/github'
require_relative './store/json'
require_relative './store/thesaurus'
require_relative './store/with_wrapped_language'
require_relative './store/bibliotheca'
