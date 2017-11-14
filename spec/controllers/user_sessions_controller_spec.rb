# frozen_string_literal: true

require 'spec_helper'

describe UserSessionsController do

  let(:user) { create(:user, activated_at: Time.new(2007,1,1)) }

  context "create" do
    context "after failed to login more than consecutive login limit" do
      before do
        allow(UserSession).to receive(:consecutive_failed_logins_limit).and_return(2)
        3.times do
          post :create, params: { user_session: { login: user.login, password: "aaa", remember_me: true } }
        end
      end

      context "when trying to login" do
        before do
          post :create, params: { user_session: { login: user.login, password: user.password, remember_me: true } }
        end

        it "should not succeed because user is locked" do
          expect(flash.now[:error]).to match("Your account has been locked")
        end
      end
    end
  end
end
