require 'spec_helper'

describe Mumukit::Sync::Store::Github::GuideWriter do

  let(:bot) { Mumukit::Sunc::Store::Github::Bot.new('mumukibot', 'zaraza') }
  let(:dir) { 'spec/data/export' }
  let(:writer) { Mumukit::Sync::Store::Github::GuideWriter.new(dir) }

  before { Dir.mkdir(dir) }
  after { FileUtils.rm_rf(dir) }

  context 'full guide' do
    let!(:exercise_1) { guide[:exercises].first }
    let(:exercise_2) { guide[:exercises].second }
    let(:exercise_3) { guide[:exercises].third }
    let(:exercise_4) { guide[:exercises].fourth }

    let(:guide) { {
        name: 'Guide Name',
        description: 'Baz',
        slug: 'flbulgarelli/never-existent-repo',
        language: {
          name: 'haskell',
          extension: 'hs',
          test_extension: 'hs'
        },
        teacher_info: 'an info',
        locale: 'en',
        type: 'practice',
        beta: false,
        id_format: '%05d',
        extra: 'Foo',
        authors: 'Foo Bar',
        collaborators: 'Jhon Doe',
        expectations: [{binding: '*', inspection: 'Not:UsesIf'}],
        exercises: [

            {name: 'foo',
            id: 100,
            position: 1,
            locale: 'en',
            tag_list: %w(foo bar),
            extra: 'foobar',
            expectations: [{binding: 'bar', inspection: 'HasBinding'}]},

            {description: 'a description',
            name: 'bar',
            tag_list: %w(baz bar),
            id: 200,
            position: 2,
            type: 'problem',
            layout: 'input_right',
            editor: 'code',
            extra_visible: false,
            manual_evaluation: false,
            choices: [],
            test: 'foo bar'},

            {description: 'a multiple',
            name: 'multiple',
            tag_list: %w(mult),
            id: 300,
            language: {
              name: 'text',
              extension: 'txt',
              test_extension: 'yml'
            },
            editor: 'multiple_choice',
            position: 3,
            type: 'problem',
            extra_visible: false,
            layout: 'input_right',
            manual_evaluation: false,
            choices: [{'value' => 'foo', 'checked' => true}, {'value' => 'bar', 'checked' => false}],
            test: "---\nequal: '0'\n"
            },

            {description: 'an exercises with characters that are not FS friendly',
            name: 'with/rare\\characters<in>its|name.',
            tag_list: %w(mult),
            id: 400,
            language: {
              name: 'text',
              extension: 'txt',
              test_extension: 'yml'
            },
            editor: 'multiple_choice',
            position: 3,
            type: 'problem',
            extra_visible: false,
            layout: 'input_right',
            manual_evaluation: false,
            choices: [{'value' => 'foo', 'checked' => true}, {'value' => 'bar', 'checked' => false}]
            }]} }

    describe 'write methods' do
      describe '#write_exercise' do
        context 'with extra' do
          before { writer.write_exercise! guide, exercise_1 }

          it { expect(File.exist? 'spec/data/export/00100_foo/extra.hs').to be true }
          it { expect(File.read 'spec/data/export/00100_foo/extra.hs').to eq 'foobar' }
        end

        context 'without extra' do
          before { writer.write_exercise! guide, exercise_2 }

          it { expect(File.exist? 'spec/data/export/00200_bar/extra.hs').to be false }
        end

        context 'with expectations' do
          before { writer.write_exercise! guide, exercise_1 }

          it { expect(File.exist? 'spec/data/export/00100_foo/expectations.yml').to be true }
          it { expect(File.read 'spec/data/export/00100_foo/expectations.yml').to eq "---\nexpectations:\n- binding: bar\n  inspection: HasBinding\n" }
        end

        context 'without expectations' do
          before { writer.write_exercise! guide, exercise_2 }

          it { expect(Dir.exist? 'spec/data/export/00200_bar/').to be true }

          it { expect(File.exist? 'spec/data/export/00200_bar/description.md').to be true }
          it { expect(File.read 'spec/data/export/00200_bar/description.md').to eq 'a description' }

          it { expect(File.exist? 'spec/data/export/00200_bar/meta.yml').to be true }
          it { expect(File.read 'spec/data/export/00200_bar/meta.yml').to eq "---\ntags:\n- baz\n- bar\nlayout: input_right\neditor: code\ntype: problem\nname: bar\n" }


          it { expect(File.exist? 'spec/data/export/00200_bar/test.hs').to be true }
          it { expect(File.read 'spec/data/export/00200_bar/test.hs').to eq 'foo bar' }

          it { expect(File.exist? 'spec/data/export/00200_bar/expectations.yml').to be false }
        end

        context 'with multiple' do
          before { writer.write_exercise! guide, exercise_3 }

          it { expect(Dir.exist? 'spec/data/export/00300_multiple/').to be true }

          it { expect(File.exist? 'spec/data/export/00300_multiple/description.md').to be true }
          it { expect(File.read 'spec/data/export/00300_multiple/description.md').to eq 'a multiple' }

          it { expect(File.exist? 'spec/data/export/00300_multiple/meta.yml').to be true }
          it { expect(File.read 'spec/data/export/00300_multiple/meta.yml').to eq "---\ntags:\n- mult\nlayout: input_right\neditor: multiple_choice\ntype: problem\nlanguage: text\nname: multiple\n" }


          it { expect(File.exist? 'spec/data/export/00300_multiple/test.yml').to be true }
          it { expect(File.read 'spec/data/export/00300_multiple/test.yml').to eq "---\nequal: '0'\n" }

          it { expect(File.exist? 'spec/data/export/00300_multiple/expectations.yml').to be false }
        end

        context 'with rare characters' do
          before { writer.write_exercise! guide, exercise_4 }

          it { expect(Dir.exist? 'spec/data/export/00400_with_rare_characters_in_its_name_/').to be true }

          it { expect(File.exist? 'spec/data/export/00400_with_rare_characters_in_its_name_/meta.yml').to be true }
          it { expect(File.read 'spec/data/export/00400_with_rare_characters_in_its_name_/meta.yml').to eq "---\ntags:\n- mult\nlayout: input_right\neditor: multiple_choice\ntype: problem\nlanguage: text\nname: with/rare\\characters<in>its|name.\n" }
        end

      end

      describe '#write_licenses' do
        before { writer.write_licenses! guide }
        context 'with copyright' do
          it { expect(File.exist? 'spec/data/export/COPYRIGHT.txt').to be true }
          it { expect(File.read 'spec/data/export/COPYRIGHT.txt').to eq "Copyright Foo Bar and contributors\n\nThis content consists of voluntary contributions made by many\nindividuals. For exact contribution history, see its revision history\navailable at https://github.com/flbulgarelli/never-existent-repo and the AUTHORS.txt file.\n" }
        end
        context 'with readme' do
          it { expect(File.exist? 'spec/data/export/README.md').to be true }
          it { expect(File.read 'spec/data/export/README.md').to eq "## License\n![License icon](https://licensebuttons.net/l/by-sa/3.0/88x31.png)\n\nThis content is distributed under Creative Commons License Share-Alike, 4.0. [https://creativecommons.org/licenses/by-sa/4.0/](https://creativecommons.org/licenses/by-sa/4.0)\n\nCopyright Foo Bar and contributors\n\nThis content consists of voluntary contributions made by many\nindividuals. For exact contribution history, see its revision history\navailable at https://github.com/flbulgarelli/never-existent-repo and the AUTHORS.txt file.\n\n" }
        end
        context 'with license' do
          it { expect(File.exist? 'spec/data/export/LICENSE.txt').to be true }
          it { expect(File.read 'spec/data/export/LICENSE.txt').to include 'Attribution-ShareAlike 4.0 International' }
        end
      end

      describe '#write_guide_files' do
        before { writer.write_guide! guide }

        it { expect(Dir.exist? 'spec/data/export/').to be true }
        it { expect(Dir.exist? 'spec/data/export/00100_foo/').to be true }
        it { expect(Dir.exist? 'spec/data/export/00200_bar/').to be true }
        it { expect(Dir.exist? 'spec/data/export/00300_multiple/').to be true }
        it { expect(File.exist? 'spec/data/export/description.md').to be true }
        it { expect(File.exist? 'spec/data/export/meta.yml').to be true }
        it { expect(File.exist? 'spec/data/export/AUTHORS.txt').to be true }
        it { expect(File.exist? 'spec/data/export/README.md').to be true }
        it { expect(File.exist? 'spec/data/export/LICENSE.txt').to be true }
        it { expect(File.exist? 'spec/data/export/COPYRIGHT.txt').to be true }
        it { expect(File.exist? 'spec/data/export/COLLABORATORS.txt').to be true }
        it { expect(File.exist? 'spec/data/export/expectations.yml').to be true }

        it { expect(File.read 'spec/data/export/meta.yml').to eq "---\nname: Guide Name\nlocale: en\nbeta: false\nlanguage: haskell\nid_format: \"%05d\"\norder:\n- 100\n- 200\n- 300\n- 400\n" }
        it { expect(File.read 'spec/data/export/description.md').to eq 'Baz' }
        it { expect(File.read 'spec/data/export/AUTHORS.txt').to eq 'Foo Bar' }
        it { expect(File.read 'spec/data/export/COLLABORATORS.txt').to eq 'Jhon Doe' }
        it { expect(File.read 'spec/data/export/expectations.yml').to eq "---\nexpectations:\n- binding: \"*\"\n  inspection: Not:UsesIf\n" }
      end
    end
    context 'guide without exercises' do
      let(:guide) do
        {
          name: 'SQL Introduction',
          description: 'SQL is....',
          slug: 'mumukiproject/introduction-to-sql',
          language: {
            name: 'sql',
            extension: 'sql',
            test_extension: 'yaml'
          },
          teacher_info: 'an info',
          sources: 'From TI4',
          learn_more: 'See mumuki.io...',
          locale: 'en',
          type: 'learning',
          authors: 'Gus & Na',
          exercises: []
        }
      end

      before { writer.write_guide! guide }

      it { expect(Dir.exist? 'spec/data/export/').to be true }
      it { expect(File.exist? 'spec/data/export/description.md').to be true }
      it { expect(File.exist? 'spec/data/export/meta.yml').to be true }
      it { expect(File.exist? 'spec/data/export/extra.hs').to be false }
      it { expect(File.exist? 'spec/data/export/AUTHORS.txt').to be true }
      it { expect(File.exist? 'spec/data/export/README.md').to be true }
      it { expect(File.exist? 'spec/data/export/LICENSE.txt').to be true }
      it { expect(File.exist? 'spec/data/export/COPYRIGHT.txt').to be true }
      it { expect(File.exist? 'spec/data/export/COLLABORATORS.txt').to be false }
      it { expect(File.exist? 'spec/data/export/expectations.yml').to be false }
      it { expect(File.exist? 'spec/data/export/expectations.yml').to be false }

      it { expect(File.read 'spec/data/export/meta.yml').to eq "---\nname: SQL Introduction\nlocale: en\nlanguage: sql\norder: []\n" }
      it { expect(File.read 'spec/data/export/description.md').to eq 'SQL is....' }
      it { expect(File.read 'spec/data/export/AUTHORS.txt').to eq 'Gus & Na' }
    end
  end
end
