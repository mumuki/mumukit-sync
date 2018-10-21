require 'spec_helper'

describe Mumukit::Sync::Store::Github::Log do
  let(:log) { Mumukit::Sync::Store::Github::Log.new }

  describe 'pre validation errors' do
    before do
      log.no_description('isEven')
      log.no_meta('isEven')
    end

    it { expect(log.to_s).to eq 'Description does not exist for isEven, Meta does not exist for isEven' }
  end
end
