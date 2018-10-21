require 'spec_helper'

describe Mumukit::Sync::Store::Github::GuideReader do
  context 'when optional properties are specified' do
    let(:log) { Mumukit::Sync::Store::Github::Log.new }
    let(:repo) { Mumukit::Auth::Slug.new('mumuki', 'functional-haskell-guide-1') }
    let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/full-guide', repo, log) }
    let!(:guide) { reader.read_guide! }

    context 'when removing that properties and reimporting the guide' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/simple-guide', repo, log) }
      let!(:guide) { reader.read_guide! }

      it { expect(guide[:id_format]).to eq '%05d' }
      it { expect(guide[:type]).to eq 'practice' }
      it { expect(guide[:beta]).to be nil }
      it { expect(guide[:language][:name]).to eq 'haskell' }
      it { expect(guide[:locale]).to eq 'en' }
      it { expect(guide[:teacher_info]).to eq 'information' }
    end
  end
end
