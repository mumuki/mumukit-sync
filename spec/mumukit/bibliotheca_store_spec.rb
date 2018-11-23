describe Mumukit::Sync::Store::Bibliotheca do
  describe 'sync_keys_matching' do
    let(:bridge) { Mumukit::Bridge::Bibliotheca.new('http://nonexistenurl.com') }
    let(:store) { Mumukit::Sync::Store::Bibliotheca.new bridge }
    let(:syncer) { Mumukit::Sync::Syncer.new store }
    let(:append_resources) { proc { |resource_type, slug| imported_resources << [resource_type, slug] } }

    before do
      expect(bridge).to receive(:get_collection).and_return(
        [{'slug' => 'foo/a-guide'}, {'slug' => 'baz/a-guide'}, {'slug' => 'foo/another-guide'}],
        [{'slug' => 'foo/a-topic'}, {'slug' => 'baz/a-topic'}],
        [])
    end

    context 'all match' do
      subject { syncer.sync_keys_matching }
      it do
        is_expected.to eq [
          Mumukit::Sync.key('guide', 'foo/a-guide'),
          Mumukit::Sync.key('guide', 'baz/a-guide'),
          Mumukit::Sync.key('guide', 'foo/another-guide'),
          Mumukit::Sync.key('topic', 'foo/a-topic'),
          Mumukit::Sync.key('topic', 'baz/a-topic')
        ]
      end
    end

    context 'some match' do
      subject { syncer.sync_keys_matching(/^foo.*$/) }
      it do
        is_expected.to eq [
          Mumukit::Sync.key('guide', 'foo/a-guide'),
          Mumukit::Sync.key('guide', 'foo/another-guide'),
          Mumukit::Sync.key('topic', 'foo/a-topic')
        ]
      end
    end
  end

  describe 'read_resource' do
    class Guide
      def self.whitelist_attributes(json, _options = {})
        json
      end
    end

    let(:bridge) { Mumukit::Bridge::Bibliotheca.new('http://nonexistenurl.com') }
    let(:store) { Mumukit::Sync::Store::Bibliotheca.new bridge }
    let(:sync_key) { struct kind: :guide, id: 'foo/bar' }

    let(:guide_hash) { {
        id: 'abe61891',
        exercises: [ { id: 1, language: 'text' } ],
        slug: 'foo/bar',
        language: 'java'
    } }

    before do
      expect(bridge).to receive(:guide).and_return guide_hash
    end

    context 'wraps languages' do
      it { expect(store.read_resource(sync_key)).to eq(exercises: [ { id: 1, language: { name: 'text' } } ],
                                                       slug: 'foo/bar',
                                                       language: { name: 'java' }) }
    end
  end
end
