require 'spec_helper'

describe Mumukit::Sync::Inflator do
  let(:gobstones) { { name: 'gobstones', extension: 'gbs', test_extension: 'yml' } }
  let(:text) { { name: 'text', extension: 'txt', test_extension: 'yml' } }

  let(:guide_language) { gobstones }
  let(:guide_resource_h) {
    {
      name: 'sample guide',
      description: 'Baz',
      slug: 'mumuki/sample-guide',
      language: guide_language,
      locale: 'en',
      extra: 'bar',
      teacher_info: 'an info',
      authors: 'Foo Bar',
      exercises: [ exercise_api_json ]
    }
  }

  subject { guide_resource_h[:exercises].first }

  before { Mumukit::Sync::Inflator.inflate_with! Mumukit::Sync.key(:guide, 'mumuki/sample-guide'), guide_resource_h, [inflator.new] }

  describe 'choices import' do
    describe 'process multiple choices' do
      let(:inflator) { Mumukit::Sync::Inflator::MultipleChoice }
      let(:exercise_api_json) { {
        type: 'problem',
        name: 'Multiple',
        description: 'a description',
        language: text,
        editor: 'multiple_choice',
        choices: [{value: 'foo', checked: true}, {value: 'bar', checked: false}, {value: 'baz', checked: true}],
        tag_list: %w(baz bar),
        layout: 'input_bottom',
        id: 2} }

      it { expect(subject[:test]).to eq "---\nequal: '0:2'\n" }
    end

    describe 'process single choices with non-text language' do
      let(:inflator) { Mumukit::Sync::Inflator::SingleChoice }

      let(:exercise_api_json) { {
        type: 'problem',
        name: 'Single',
        description: 'a big problem',
        language: gobstones,
        test: 'foo',
        editor: 'single_choice',
        choices: [{value: 'foo', checked: true}, {value: 'bar', checked: false}, {value: 'baz', checked: false}],
        tag_list: %w(baz bar),
        layout: 'input_bottom',
        id: 2} }

      it { expect(subject[:test]).to eq "foo" }
    end

    describe 'process single choices with text language' do
      let(:inflator) { Mumukit::Sync::Inflator::SingleChoice }

      let(:exercise_api_json) { {
        type: 'problem',
        name: 'Single',
        description: 'a big problem',
        language: text,
        editor: 'single_choice',
        choices: [{value: 'foo', checked: true}, {value: 'bar', checked: false}, {value: 'baz', checked: false}],
        tag_list: %w(baz bar),
        layout: 'input_bottom',
        id: 2} }

      it { expect(subject[:test]).to eq "---\nequal: foo\n" }
    end

    describe 'process single choices with text language in guide' do
      let(:inflator) { Mumukit::Sync::Inflator::SingleChoice }

      let(:guide_language) { text }
      let(:exercise_api_json) { {
        type: 'problem',
        name: 'Single',
        description: 'a big problem',
        editor: 'single_choice',
        choices: [{value: 'foo', checked: true}, {value: 'bar', checked: false}, {value: 'baz', checked: false}],
        tag_list: %w(baz bar),
        layout: 'input_bottom',
        id: 2} }

      it { expect(subject[:test]).to eq "---\nequal: foo\n" }
    end
  end
end
