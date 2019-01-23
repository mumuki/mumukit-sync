class Mumukit::Sync::Store::Github
  class GuideExport < Mumukit::Sync::Store::Github::Operation

    attr_accessor :guide_resource_h, :bot, :author_email

    def initialize(options)
      super(options)
      @guide_resource_h = options[:document]
      @author_email = options[:author_email]
    end

    def repo
      @repo ||= Mumukit::Auth::Slug.parse(guide_resource_h[:slug])
    end

    def can_run?
      bot.authenticated?
    end

    def before_run_in_local_repo
      bot.ensure_exists! repo, guide_resource_h[:private]
    end

    def run_in_local_repo(dir, local_repo)
      clear_repo local_repo
      GuideWriter.new(dir).write_guide! guide_resource_h
      local_repo.add(all: true)
      local_repo.commit("Mumuki Export on #{Time.now}", commit_options)
      local_repo.push
    rescue StandardError => e
      puts "Could not export guide #{guide_resource_h[:slug]} to git #{e}"
    end


    private

    def commit_options
      author_email.present? ? {author: "#{author_email} <#{author_email}>"} : {}
    end

    def clear_repo(local_repo)
      local_repo.remove %w(
        LICENSE.txt
        README.md
        COPYRIGHT.txt
        AUTHORS.txt
        COLLABORATORS.txt
        description.md
        corollary.md
        sources.md
        learn_more.md
        meta.yml
        extra.yml
        expectations.* *_*/*) # FIXME autogenerate this list
    rescue Git::GitExecuteError => e
      puts 'Nothing to clean, repo seems to be empty'
    end
  end

  class OrganizationNotFoundError < StandardError
  end
end
