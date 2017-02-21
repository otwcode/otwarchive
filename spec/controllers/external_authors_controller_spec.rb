# frozen_string_literal: true
require 'spec_helper'

describe ExternalAuthorsController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { FactoryGirl.create(:user) }


  describe "GET #index" do
    it "redirects and gives a notice when not logged in" do
      get :index
      it_redirects_to_with_notice(root_path, "You can't see that information.")
    end

    it "assigns @external_authors" do
      external_author = FactoryGirl.create(:external_author)
      user = FactoryGirl.create(:user)
      external_author.claim!(user)     
      fake_login_known_user(user)
      get :index, user_id: user.login
      expect(assigns(:external_authors)).to eq([external_author])
    end

    it "assigns @external_authors when an archivist" do
      external_creatorship = FactoryGirl.create(:external_creatorship)
      archivist = FactoryGirl.create(:user )
      fake_login_known_user(archivist)
      allow_any_instance_of(User).to receive(:is_archivist?).and_return(true)
      get :index, user_id: user.login
      allow_any_instance_of(User).to receive(:is_archivist?).and_call_original
      expect(assigns(:external_authors)).to eq([])
    end
  end
end
