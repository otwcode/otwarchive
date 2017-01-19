require 'spec_helper'

# This spec tests the challenges_controller.rb file. There is no need to test
# the load_collection method directly, as that is done en route to testing the
# other two methods contained in that controller.

describe ChallengesController do
  describe 'no_collection' do
    it 'should show an error, redirect and return false' do
      get :no_collection
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq "What collection did you want to work with?"
    end
  end

  describe 'no_challenge' do
    before(:each) do
      @collection = FactoryGirl.create(:collection, challenge: GiftExchange.new)
      @collection.save
    end
    context 'when a collection is available' do
      it 'should show an error message, redirect and return false' do
        get :no_challenge, collection_id: @collection.name
        expect(response).to redirect_to(collection_path(@collection))
        expect(flash[:error]).to eq "What challenge did you want to work on?"
      end
    end

    context 'when no collection is unavailable' do
      it 'should show a no collection error message, redirect, return false' do
        get :no_challenge
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq "What collection did you want to work with?"
      end
    end
  end

  describe 'load_challenge' do
    before(:each) do
      @collection2 = FactoryGirl.create(:collection, challenge: GiftExchange.new)
      @collection2.save
    end
    context 'when a challenge is available' do
      # I cannot figure out how to make this one work.
      xit 'should return a challenge variable' do
        controller.instance_variable_set(:@collection, @collection2)
        get :load_challenge
        expect(flash[:error]).to be_nil
        expect(response).to be_nil
      end
    end
  end
end
