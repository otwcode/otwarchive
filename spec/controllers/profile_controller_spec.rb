require 'spec_helper'

describe ProfileController do
  describe 'show' do
    it 'should be an error for a non existent user' do
      get :show, params: { user_id: 999_999_999_999 }

      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq "Sorry, there's no user by that name."
    end

    it 'should create a new profile if one does not exist' do
      @user = FactoryBot.create(:user)
      @user.profile.destroy
      @user.reload
      get :show, params: { user_id: @user }
      expect(@user.profile).to be
    end

    it 'uses the profile presenter for the profile' do
      @user = FactoryBot.create(:user)
      profile_presenter = double(:profile_presenter)
      allow(ProfilePresenter).to receive(:new).and_return(profile_presenter)

      get :show, params: { user_id: @user }

      expect(assigns(:profile)).to eq(profile_presenter)
    end
  end
end
