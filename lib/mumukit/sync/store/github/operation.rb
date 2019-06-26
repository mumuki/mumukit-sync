class Mumukit::Sync::Store::Github
  class Operation
    attr_accessor :bot

    def initialize(options)
      @bot = options[:bot]
      @web_hook_base_url = options[:web_hook_base_url]
      @exercise_schema = options[:exercise_schema]
    end

    def with_local_repo(&block)
      Dir.mktmpdir("mumuki.#{self.class.name}") do |dir|
        bot.clone_into repo, dir, &block
      end
    end

    def can_run?
      true
    end

    def run!
      return unless can_run?

      puts "#{self.class.name} : running before run hook for repository #{repo}"
      before_run_in_local_repo

      result = nil
      with_local_repo do |dir, local_repo|
        puts "#{self.class.name} : running run hook for repository #{repo}"
        result = run_in_local_repo dir, local_repo
      end

      puts "#{self.class.name} : running after run hook repository #{repo}"
      ensure_post_commit_hook!
      result
    end

    def ensure_post_commit_hook!
      bot.register_post_commit_hook!(repo, @web_hook_base_url) if bot.authenticated? && @web_hook_base_url
    end

    def before_run_in_local_repo
    end

    def run_in_local_repo(dir, local_repo)
    end
  end
end
