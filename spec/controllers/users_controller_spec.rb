require 'spec_helper'

class UsersController < ApplicationController

  def check_account_creation_status
    true
  end

end

describe UsersController do

  def valid_user_attributes
    { email: "sna.foo@gmail.com", login: "myname", age_over_13: "1",
      terms_of_service: "1", password: "password" }
  end

  describe "create" do

    context "with valid parameters" do
      it "should be successful" do
        post :create, user: valid_user_attributes

        expect(response).to be_success
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to eq(User.last)
      end
    end

  end

end
