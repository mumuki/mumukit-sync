require 'spec_helper'

def position_after_ordering(ordering, position)
  ordering.position_for(position)
end

describe Mumukit::Sync::Store::Github::Ordering do

  it { expect(Mumukit::Sync::Store::Github::Ordering.from(nil)).to be Mumukit::Sync::Store::Github::NaturalOrdering }
  it { expect(Mumukit::Sync::Store::Github::Ordering.from([2, 3, 4])).to be_a Mumukit::Sync::Store::Github::FixedOrdering }

  it { expect(position_after_ordering(Mumukit::Sync::Store::Github::NaturalOrdering, 4)).to eq 4 }

  describe Mumukit::Sync::Store::Github::FixedOrdering do
    let(:ordering) { Mumukit::Sync::Store::Github::FixedOrdering.new([4, 20, 3]) }

    it { expect(ordering.position_for(20)).to eq 2 }

    it { expect(position_after_ordering(ordering, 4)).to eq(1) }
    it { expect(position_after_ordering(ordering, 20)).to eq(2) }
    it { expect(position_after_ordering(ordering, 3)).to eq(3) }
  end
end
