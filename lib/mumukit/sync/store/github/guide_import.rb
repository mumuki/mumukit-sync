class Mumukit::Sync::Store::Github
  class GuideImport < Mumukit::Sync::Store::Github::Operation
    attr_accessor :repo, :guide

    def initialize(options)
      super(options)
      @repo = options[:repo]
    end

    def run_in_local_repo(dir, local_repo)
      GuideReader.new(dir, repo).read_guide!
    end
  end
end
