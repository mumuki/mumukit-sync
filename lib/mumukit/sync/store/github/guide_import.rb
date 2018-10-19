class Mumukit::Sync::Store::Github
  class GuideImport < Mumukit::Sync::Store::Github::Operation
    attr_accessor :repo, :guide

    def initialize(options)
      super(options)
      @repo = options[:repo]
    end

    def run_in_local_repo(dir, local_repo)
      @guide = GuideReader.new(dir, repo, log).read_guide!
      @guide.validate!
    end

    def after_run_in_local_repo
      Bibliotheca::Collection::Guides.upsert_by_slug(guide.slug, guide)
    end
  end
end
