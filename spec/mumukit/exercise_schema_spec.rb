require 'spec_helper'

describe 'Mumukit::Sync::Store::Github::Schema::Field' do
  let(:exercise) { { bar: 4 } }

  describe 'when reverse field specified' do
    let(:field) { Mumukit::Sync::Store::Github::Schema::Field.new(kind: :metadata, name: :foo, reverse: :bar) }

    it { expect(field.name).to eq :foo }
    it { expect(field.reverse_name).to eq :bar }
    it { expect(field.get_field_value(exercise)).to eq 4 }
  end

  describe 'when no reverse field specified' do
    let(:field) { Mumukit::Sync::Store::Github::Schema::Field.new(kind: :metadata, name: :bar) }

    it { expect(field.name).to eq :bar }
    it { expect(field.reverse_name).to eq :bar }
    it { expect(field.get_field_value(exercise)).to eq 4 }

  end
end
