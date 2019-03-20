require 'spec_helper'

describe Mumukit::Sync::Store::Github::Bot do
  let(:token) { 'thegithubtoken' }
  let(:bot) { Mumukit::Sync::Store::Github::Bot.new 'user', 'user@mail.com', token }

  it 'when there is a git error token is not dumped in the error message' do
    expect { bot.clone_into 'foo/bar'.to_mumukit_slug, '.' }.to raise_error { |error| expect(error.message).to_not include(token) }
  end
end
