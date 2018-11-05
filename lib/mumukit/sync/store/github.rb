module Mumukit::Sync::Store
  class Github
    def initialize(bot, author_email = nil, web_hook_base_url = nil)
      @bot = bot
      @author_email = author_email || bot.email
      @web_hook_base_url = web_hook_base_url
    end

    def sync_keys
      raise 'Non-discoverable store'
    end

    def read_resource(sync_key)
      return unless sync_key.kind == :guide

      Mumukit::Sync::Store::Github::GuideImport.new(
        bot: @bot,
        repo: sync_key.id,
        web_hook_base_url: @web_hook_base_url).run!
    end

    def write_resource!(sync_key, resource_h)
      return unless sync_key.kind == :guide

      Mumukit::Sync::Store::Github::GuideExport.new(
        slug: sync_key.id,
        document: resource_h,
        author_email: @author_email,
        web_hook_base_url: @web_hook_base_url,
        bot: @bot).run!
    end
  end

  ## FIXME REMOVE
  class Github::Bot
    def fork!(slug, fork_organization)
      octokit.fork slug.to_s, {organization: fork_organization}
    end

    def upload_asset!(slug, filename, content)
      path = "assets/#{filename.gsub(/\.(.*){2,4}/) { |it| "_#{(Time.now.to_f * 1000).to_i}#{it}" }}"
      octokit.create_contents(slug.to_s,
                              path,
                              'Uploading new asset',
                              content).content.to_h
    end
  end
end

require 'mumukit/auth'

require_relative './github/bot'
require_relative './github/git_lib'
require_relative './github/with_file_reading'
require_relative './github/guide_reader'
require_relative './github/guide_builder'
require_relative './github/exercise_builder'
require_relative './github/guide_writer'
require_relative './github/operation'
require_relative './github/guide_export'
require_relative './github/guide_import'
require_relative './github/ordering'
require_relative './github/schema'
