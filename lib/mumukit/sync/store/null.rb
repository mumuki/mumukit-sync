module Mumukit::Sync::Store
  class NullStore
    def write_resource!(*)
    end

    def read_resource(key)
      raise "#{key.kind} #{key.id} not found"
    end
  end
end
