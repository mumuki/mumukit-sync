require 'spec_helper'

describe Mumukit::Sync::Store::Github::GuideReader do
  let(:repo) { Mumukit::Auth::Slug.new('mumuki', 'functional-haskell-guide-1') }

  def find_exercise_by_id(guide, id)
    guide[:exercises].find { |it| it[:id] == id }
  end

  describe 'read_exercises' do
    let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/broken-guide', repo) }

    it { expect { reader.read_guide! }.to raise_error('Missing description file') }
  end

  describe '#read_guide!' do
    context 'when guide is ok' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/simple-guide', repo) }
      let(:guide) { reader.read_guide! }

      it { expect(guide[:slug]).to eq 'mumuki/functional-haskell-guide-1'}
      it { expect(guide[:exercises].count).to eq 6 }
      it { expect(guide[:description]).to eq "Awesome guide\n" }
      it { expect(guide[:language][:name]).to eq 'haskell' }
      it { expect(guide[:locale]).to eq 'en' }
      it { expect(guide[:teacher_info]).to eq 'information' }

      context 'when importing basic exercise' do
        let(:imported_exercise) { find_exercise_by_id(guide, 1) }

        it { expect(imported_exercise).to_not be nil }
        it { expect(imported_exercise[:default_content]).to_not be nil }
        it { expect(imported_exercise[:author]).to eq guide[:author] }
        it { expect(imported_exercise[:name]).to eq 'sample_title' }
        it { expect(imported_exercise[:extra_visible]).to be true }
        it { expect(imported_exercise[:description]).to eq '##Sample Description' }
        it { expect(imported_exercise[:test]).to eq 'pending' }
        it { expect(imported_exercise[:extra]).to eq "extra\n" }
        it { expect(imported_exercise[:hint]).to be nil }
        it { expect(imported_exercise[:teacher_info]).to eq 'information' }
        it { expect(imported_exercise[:corollary]).to be nil }
        it { expect(imported_exercise[:expectations].size).to eq 2 }
        it { expect(imported_exercise[:tag_list]).to include *%w(foo bar baz) }
        it { expect(guide[:description]).to eq "Awesome guide\n" }
        it { expect(imported_exercise[:layout]).to be nil }

      end

      context 'when importing exercise with errors' do
        let(:imported_exercise) { find_exercise_by_id(guide, 2) }

        it { expect(imported_exercise).to be nil }
      end

      context 'when importing exercise with hint and corollary' do
        let(:imported_exercise) { find_exercise_by_id(guide, 3) }

        it { expect(imported_exercise).to_not be nil }
        it { expect(imported_exercise[:name]).to eq "custom_name" }
        it { expect(imported_exercise[:hint]).to eq "Try this: blah blah\n" }
        it { expect(imported_exercise[:corollary]).to eq "And the corollary is...\n" }
      end

      context 'when importing with layout' do
        let(:imported_exercise) { find_exercise_by_id(guide, 4) }

        it { expect(imported_exercise).to_not be nil }
        it { expect(imported_exercise[:layout]).to eq 'input_bottom' }
      end

      context 'when importing playground' do
        let(:imported_exercise) { find_exercise_by_id(guide, 5) }

        it { expect(imported_exercise).to_not be nil }
        it { expect(imported_exercise[:name]).to eq 'playground' }
        it { expect(imported_exercise[:type]).to eq 'playground' }

      end

      context 'when importing reading' do
        let(:imported_exercise) { find_exercise_by_id(guide, 6) }

        it { expect(imported_exercise).to_not be nil }
        it { expect(imported_exercise[:name]).to eq 'reading' }
        it { expect(imported_exercise[:type]).to eq 'reading' }
        it { expect(imported_exercise[:test]).to be_blank}
        it { expect(imported_exercise[:expectations]).to be_blank }
        it { expect(imported_exercise[:hint]).to be_blank }
        it { expect(imported_exercise[:corollary]).to be_blank }
        it { expect(imported_exercise[:extra]).to be_blank }
        it { expect(imported_exercise[:description]).to eq "Now read the following text\n"}

      end

      context 'when importing free_form' do
        let(:imported_exercise) { find_exercise_by_id(guide, 7) }

        it { expect(imported_exercise).to_not be nil }
        it { expect(imported_exercise[:free_form_editor_source]).to_not be_nil}
      end
    end

    context 'when guide is incomplete' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/incompelete-guide', repo) }

      it 'fails' do
        expect { reader.read_guide! }.to raise_error('Missing meta.yml')
      end
    end
    context 'when guide has full data' do
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/full-guide', repo) }
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
      let(:reader) { Mumukit::Sync::Store::Github::GuideReader.new('spec/data/legacy-guide', repo) }
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
