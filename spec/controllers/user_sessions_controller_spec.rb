# frozen_string_literal: true

require "spec_helper"

describe UserSessionsController do
  let(:user) { create(:user, activated_at: Time.new(2007, 1, 1)) }

  context "create" do
    context "after failed to login more than consecutive login limit" do
      before do
        max_consecutive_attempts = 2
        allow(UserSession).to receive(:consecutive_failed_logins_limit).and_return(max_consecutive_attempts)
        max_consecutive_attempts.times do
          post :create, params: { user_session: { login: user.login, password: "aaa" } }
        end
      end

      it "should not succeed because user is locked" do
        post :create, params: { user_session: { login: user.login, password: user.password } }
        expect(flash[:error]).to match("Your account has been locked")
      end
    end
  end
end
