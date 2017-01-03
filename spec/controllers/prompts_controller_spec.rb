require 'spec_helper'

describe PromptsController do
  include LoginMacros

  before do
    fake_login
  end

  describe 'no_prompt' do
   it 'should show an error and redirect' do
      signups = create(:challenge_signup)
      post :edit,  collection_id: signups.collection.name
      expect(response).to redirect_to(collection_path(signups.collection))
      expect(flash[:error]).to eq "What prompt did you want to work on?"
    end
  end

end
