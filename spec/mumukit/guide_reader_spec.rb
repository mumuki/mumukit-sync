require 'spec_helper'

describe Mumukit::Sync::Store::Github::GuideReader do
  let(:repo) { Mumukit::Auth::Slug.new('mumuki', 'functional-haskell-guide-1') }
  let(:exercise_schema) { Mumukit::Sync::Store::Github::Schema::Exercise.new }


  def find_exercise_by_id(guide, id)
    guide[:exercises].find { |it| it[:id] == id }
  end


  describe '#read_guide!' do
    context 'guide description is missing' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/broken-guide-missing-description', repo, exercise_schema) }
      it { expect { reader.read_guide! }.to raise_error('Missing guide description file') }
    end

    context 'guide meta is missing' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/broken-guide-missing-meta', repo, exercise_schema) }
      it { expect { reader.read_guide! }.to raise_error('Missing guide meta.yml') }
    end

    context 'missing description' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/broken-guide', repo, exercise_schema) }
      it { expect { reader.read_guide! }.to raise_error('Missing exercise sample_broken description file') }
    end

    context 'broken synax' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/broken-guide-syntax-error', repo, exercise_schema) }
      it { expect { reader.read_guide! }.to raise_error('Bad guide metadata syntax') }
    end

    context 'missing language' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/broken-guide-missing-language', repo, exercise_schema) }
      it { expect { reader.read_guide! }.to raise_error('Missing guide language') }
    end

    context 'when guide is ok' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/simple-guide', repo, exercise_schema) }
      let(:guide) { reader.read_guide! }

      it { expect(guide[:slug]).to eq 'mumuki/functional-haskell-guide-1'}
      it { expect(guide[:exercises].count).to eq 7 }
      it { expect(guide[:description]).to eq "Awesome guide\n" }
      it { expect(guide[:language][:name]).to eq 'haskell' }
      it { expect(guide[:locale]).to eq 'en' }
      it { expect(guide[:teacher_info]).to eq 'information' }

      context 'when importing basic exercise' do
        subject { find_exercise_by_id(guide, 1) }

        it { expect(subject).to_not be nil }
        it { expect(subject[:default_content]).to_not be nil }
        it { expect(subject[:author]).to eq guide[:author] }
        it { expect(subject[:name]).to eq 'sample_title' }
        it { expect(subject[:extra_visible]).to be true }
        it { expect(subject[:description]).to eq '##Sample Description' }
        it { expect(subject[:test]).to eq 'pending' }
        it { expect(subject[:extra]).to eq "extra\n" }
        it { expect(subject[:hint]).to be nil }
        it { expect(subject[:teacher_info]).to eq 'information' }
        it { expect(subject[:corollary]).to be nil }
        it { expect(subject[:expectations].size).to eq 2 }
        it { expect(subject[:tag_list]).to include *%w(foo bar baz) }
        it { expect(subject[:layout]).to be nil }
        it { expect(subject[:language]).to be nil }
      end

      context 'when importing exercise with language override' do
        subject { find_exercise_by_id(guide, 8) }

        it { expect(subject[:language][:name]).to eq 'sqlite' }
      end

      context 'when importing exercise with errors' do
        subject { find_exercise_by_id(guide, 2) }

        it { expect(subject).to be nil }
      end

      context 'when importing exercise with hint and corollary' do
        subject { find_exercise_by_id(guide, 3) }

        it { expect(subject).to_not be nil }
        it { expect(subject[:name]).to eq "custom_name" }
        it { expect(subject[:hint]).to eq "Try this: blah blah\n" }
        it { expect(subject[:corollary]).to eq "And the corollary is...\n" }
      end

      context 'when importing with layout' do
        subject { find_exercise_by_id(guide, 4) }

        it { expect(subject).to_not be nil }
        it { expect(subject[:layout]).to eq 'input_bottom' }
      end

      context 'when importing playground' do
        subject { find_exercise_by_id(guide, 5) }

        it { expect(subject).to_not be nil }
        it { expect(subject[:name]).to eq 'playground' }
        it { expect(subject[:type]).to eq 'playground' }

      end

      context 'when importing reading' do
        subject { find_exercise_by_id(guide, 6) }

        it { expect(subject).to_not be nil }
        it { expect(subject[:name]).to eq 'reading' }
        it { expect(subject[:type]).to eq 'reading' }
        it { expect(subject[:test]).to be_blank}
        it { expect(subject[:expectations]).to be_blank }
        it { expect(subject[:hint]).to be_blank }
        it { expect(subject[:corollary]).to be_blank }
        it { expect(subject[:extra]).to be_blank }
        it { expect(subject[:description]).to eq "Now read the following text\n"}

      end

      context 'when importing free_form' do
        subject { find_exercise_by_id(guide, 7) }

        it { expect(subject).to_not be nil }
        it { expect(subject[:free_form_editor_source]).to_not be_nil}
      end
    end

    context 'when guide has full data' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/full-guide', repo, exercise_schema) }
      let!(:guide) { reader.read_guide! }

      it { expect(guide[:name]).to eq 'Introduction' }
      it { expect(guide[:authors]).to eq "Foo Bar\n" }
      it { expect(guide[:collaborators]).to eq "Jhon Doe\n" }
      it { expect(guide[:exercises].size).to eq 1 }
      it { expect(guide[:corollary]).to eq "A guide's corollary\n" }
      it { expect(guide[:type]).to eq 'learning' }
      it { expect(guide[:id_format]).to eq '%05d' }
      it { expect(guide[:beta]).to eq true }
      it { expect(guide[:extra]).to eq "A guide's extra code\n" }
    end

    context 'when guide has legacy data' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/legacy-guide', repo, exercise_schema) }
      let!(:guide) { reader.read_guide! }

      it { expect(guide[:name]).to eq 'Introduction' }
      it { expect(guide[:exercises].size).to eq 1 }
      it { expect(guide[:corollary]).to eq "A guide's corollary\n" }
      it { expect(guide[:type]).to eq 'learning' }
      it { expect(guide[:id_format]).to eq '%03d' }
      it { expect(guide[:beta]).to eq true }
      it { expect(guide[:extra]).to eq "A guide's extra code\n" }
    end
  end
end
