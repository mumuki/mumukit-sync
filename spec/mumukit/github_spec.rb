require 'spec_helper'

describe Mumukit::Sync::Store::Github do
  class Guide
    def self.locate_resource(*)
      new
    end

    def sync_key
      Mumukit::Sync.key :guide, 'pdep-utn/mumuki-funcional-guia-0'
    end

    def import_from_resource_h!(*)
    end
  end

  let(:bot) { Mumukit::Sync::Store::Github::Bot.new 'user', 'user@mail.com', token }
  let(:syncer) { Mumukit::Sync::Syncer.new Mumukit::Sync::Store::Github.new(bot, 'author', 'http://sample.com') }
  let(:slug) { 'pdep-utn/mumuki-funcional-guia-0' }

  before do
    expect_any_instance_of(Mumukit::Sync::Store::Github::GuideReader).to receive(:read_guide!).and_return({})
    expect(Git).to receive(:clone).and_return(Git::Base.new)
    allow_any_instance_of(Git::Base).to receive(:config)
  end

  context 'when bot is authenticated' do
    let(:token) {  'atoken' }
    before { expect(bot).to receive(:register_post_commit_hook!) }

    context 'when using symbol kind' do
      it { syncer.locate_and_import! :guide, slug }
    end

    context 'when using class kind' do
      it { syncer.locate_and_import! Guide, slug }
    end
  end

  context 'when bot is not authenticated' do
    let(:token) {  nil }
    before { expect(bot).to_not receive(:register_post_commit_hook!) }
    it { syncer.locate_and_import! :guide, slug }
  end
end
