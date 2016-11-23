require 'spec_helper'

describe CollectionSweeper do
  describe 'get_collections_from_record' do
    before(:each) do
      @work = FactoryGirl.create(:work)
    end

    let(:sweeper) { CollectionSweeper.instance }
    context 'for Works with no collections' do
      it 'should return an empty array' do
        expect(sweeper.get_collections_from_record(@work)).to be_nil
      end
    end
  end
end