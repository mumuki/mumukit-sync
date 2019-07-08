require 'spec_helper'

describe 'read-write' do
  let(:repo) { Mumukit::Auth::Slug.new('mumuki', 'functional-haskell-guide-1') }
  let(:guide) { {
      description: 'Baz',
      slug: 'flbulgarelli/never-existent-repo',
      language: { name: 'haskell', extension: 'hs', test_extension: 'hs' },
      locale: 'en',
      id_format: '%05d',
      exercises: [
          {type: 'problem',
           name: 'Bar',
           description: 'a description',
           test: 'foo bar',
           default_content: '--type here',
           tag_list: %w(baz bar),
           layout: 'input_bottom',
           id: 1},

          {type: 'problem',
           name: 'Foo',
           layout: 'input_right',
           tag_list: %w(foo bar),
           description: 'another description',
           id: 4},

          {name: 'Baz',
           tag_list: %w(baz bar),
           layout: 'input_bottom',
           description: 'final description',
           type: 'problem',
           id: 2}] } }

  let(:dir) { 'spec/data/import-export' }

  let(:imported_guide) do
    FileUtils.mkdir_p dir
    Mumukit::Sync::Store::Github::GuideWriter.new(dir).write_guide! guide
    Mumukit::Sync::Store::Github::GuideReader.new(dir, repo).read_guide!
  end

  after do
    FileUtils.rm_rf dir
  end

  it { expect(imported_guide[:exercises].length).to eq 3 }
  it { expect(imported_guide[:exercises].first[:name]).to eq 'Bar' }
  it { expect(imported_guide[:exercises].second[:name]).to eq 'Foo' }
  it { expect(imported_guide[:exercises].third[:name]).to eq 'Baz' }
  it { expect(imported_guide[:exercises].first[:layout]).to eq 'input_bottom' }
  it { expect(imported_guide[:exercises].second[:layout]).to eq 'input_right' }

  it { expect(imported_guide[:language][:name]).to eq 'haskell' }
  it { expect(imported_guide[:locale]).to eq 'en' }
  it { expect(imported_guide[:description]).to eq 'Baz' }


end
