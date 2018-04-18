require 'spec_helper'

describe UsersController do

  def valid_user_attributes
    {
      email: "sna.foo@gmail.com", login: "myname", age_over_13: "1",
      terms_of_service: "1", password: "password"
    }
  end

  before do
    allow_any_instance_of(UsersController).to receive(:check_account_creation_status).and_return(true)
  end

  describe "create" do

    context "with valid parameters" do
      it "should be successful" do
        post :create, params: { user: valid_user_attributes }

        expect(response).to be_success
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to eq(User.last)
      end
    end

  end

end
