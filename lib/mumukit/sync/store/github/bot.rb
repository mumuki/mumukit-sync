class Mumukit::Sync::Store::Github
  class Bot
    attr_accessor :token, :name, :email

    def initialize(name, email, token)
      ensure_present! name, email
      @name = name
      @email = email
      @token = token
    end

    def ensure_exists!(slug, private)
      create!(slug, private) unless exists?(slug)
    end

    def clone_into(repo, dir, &block)
      local_repo = Git.clone(writable_github_url_for(repo), '.', path: dir)
      local_repo.config('user.name', name)
      local_repo.config('user.email', email)
      yield dir, local_repo
    rescue Git::GitExecuteError => e
      raise Mumukit::Sync::SyncError, 'Repository is private or does not exist' if private_repo_error(e.message)
      raise Mumukit::Sync::SyncError, "Clone of #{repo} failed"
    end

    def register_post_commit_hook!(slug, web_hook_base_url)
      octokit.create_hook(
        slug.to_s, 'web',
        {url: "#{web_hook_base_url}/#{slug.to_s}", content_type: 'json'},
        {events: ['push'],
         active: true})
    rescue => e
      puts "not registering post commit hook: #{e.message}"
    end

    def authenticated?
      !!token
    end

    def self.from_env
      new ENV['MUMUKI_BOT_USERNAME'], ENV['MUMUKI_BOT_EMAIL'], ENV['MUMUKI_BOT_API_TOKEN']
    end

    private

    def exists?(slug)
      Git.ls_remote(writable_github_url_for(slug))
      true
    rescue Git::GitExecuteError
      false
    end

    def create!(slug, private)
      octokit.create_repository(slug.repository, organization: slug.organization)
      try_set_private!(slug) if private
    rescue Octokit::Forbidden
      raise raise Mumukit::Sync::SyncError, "Mumuki is not allowed to create repositories in organization #{slug.organization}"
    end

    def try_set_private!(slug)
      octokit.set_private(slug.to_s)
    rescue Octokit::NotFound
      puts "#{slug.to_s} repository can't be set as private"
    end

    def writable_github_url_for(slug)
      "https://#{name}:#{token}@github.com/#{slug}"
    end

    def octokit
      Octokit::Client.new(access_token: token)
    end

    def private_repo_error(message)
      ['could not read Username', 'Invalid username or password'].any? { |it| message.include? it }
    end
  end
end
