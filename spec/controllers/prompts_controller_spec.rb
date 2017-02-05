require 'spec_helper'

describe PromptsController do
  include LoginMacros
  include RedirectExpectationHelper

  before do
    fake_login
  end

  describe 'no_prompt' do
    it 'should show an error and redirect' do
      signups = create(:challenge_signup)
      post :edit, collection_id: signups.collection.name
      it_redirects_to_with_error(collection_path(signup.collection), "What prompt did you want to work on?")
    end
  end
end
