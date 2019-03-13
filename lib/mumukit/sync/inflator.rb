module Mumukit::Sync
  module Inflator
    def self.inflate_with!(sync_key, resource_h, inflators)
      inflators.each { |it| it.inflate! sync_key, resource_h }
    end
  end
end

require_relative './inflator/exercise'
require_relative './inflator/choice'
require_relative './inflator/single_choice'
require_relative './inflator/multiple_choice'

