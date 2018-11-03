require 'spec_helper'

describe Mumukit::Sync::Store::Github::GuideExport do
  let(:guide_resource_h) {
    {
      name: 'sample guide',
      description: 'Baz',
      slug: 'mumuki/sample-guide',
      language: { name: 'gobstones' },
      locale: 'en',
      extra: 'bar',
      teacher_info: 'an info',
      authors: 'Foo Bar',
      exercises: [ ]
    }
  }

  let(:bot) { Mumukit::Sync::Store::Github::Bot.new('bot', 'bot@foo.org', 'asdfgh') }
  let(:export) { Mumukit::Sync::Store::Github::GuideExport.new(document: guide_resource_h, bot: bot, author_email: 'johnny.cash@hotmail.com') }

  before do
    expect(bot).to receive(:create!).and_return(nil).ordered
    expect(bot).to receive(:clone_into).and_return(nil).ordered
  end

  it { expect { export.run! }.to_not raise_error }
end
