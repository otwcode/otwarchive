require 'spec_helper'

describe ProfileController do
  describe "show" do
    let(:user) { create(:user) }

    it "redirects and shows an error message for a non existent user" do
      get :show, params: { user_id: 999_999_999_999 }

      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq "Sorry, there's no user by that name."
    end

    it "creates a new profile if one does not exist" do
      user.profile.destroy
      user.reload

      get :show, params: { user_id: user }

      expect(user.profile).not_to be_nil
    end

    it "uses the profile presenter for the profile" do
      profile_presenter = instance_double(ProfilePresenter)
      allow(ProfilePresenter).to receive(:new).and_return(profile_presenter)

      get :show, params: { user_id: user }

      expect(assigns(:profile)).to eq(profile_presenter)
    end
  end
end
