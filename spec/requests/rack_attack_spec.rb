require "spec_helper"

describe "Rack::Attack", type: :request do
  before { freeze_time }

  def unique_ip_env
    { "REMOTE_ADDR" => Faker::Internet.unique.ip_v4_address }
  end

  def unique_user_params
    { user: { login: Faker::Name.unique.first_name, password: "secret" } }
  end

  it "test utility returns valid parameters for successful user login attempts" do
    params = unique_user_params
    create(:user, login: params[:user][:login], password: params[:user][:password])
    post user_session_path, params: params.to_query
    expect(response).to have_http_status(:redirect)
  end

  context "when there have been max user login attempts from an IP address" do
    let(:ip) { Faker::Internet.unique.ip_v4_address }

    before do
      ArchiveConfig.RATE_LIMIT_LOGIN_ATTEMPTS.times do
        post user_session_path, params: unique_user_params.to_query, env: { "REMOTE_ADDR" => ip }
      end
    end

    it "throttles the next attempt from the same IP" do
      post user_session_path, params: unique_user_params.to_query, env: { "REMOTE_ADDR" => ip }
      expect(response).to have_http_status(:too_many_requests)
    end

    it "does not throttle the next attempt from the same IP after some time" do
      travel ArchiveConfig.RATE_LIMIT_LOGIN_PERIOD.seconds
      post user_session_path, params: unique_user_params.to_query, env: { "REMOTE_ADDR" => ip }
      expect(response).to have_http_status(:ok)
    end

    it "does not throttle an attempt from a different IP" do
      post user_session_path, params: unique_user_params.to_query, env: unique_ip_env
      expect(response).to have_http_status(:ok)
    end
  end

  context "when there have been max user login attempts for a username" do
    let(:params) { unique_user_params.to_query }

    before do
      ArchiveConfig.RATE_LIMIT_LOGIN_ATTEMPTS.times do
        post user_session_path, params: params, env: unique_ip_env
      end
    end

    it "throttles the next attempt for the same username" do
      post user_session_path, params: params, env: unique_ip_env
      expect(response).to have_http_status(:too_many_requests)
    end

    it "does not throttle the next attempt for the same username after some time" do
      travel ArchiveConfig.RATE_LIMIT_LOGIN_PERIOD.seconds
      post user_session_path, params: params, env: unique_ip_env
      expect(response).to have_http_status(:ok)
    end

    it "does not throttle an attempt for a different username" do
      post user_session_path, params: unique_user_params.to_query, env: unique_ip_env
      expect(response).to have_http_status(:ok)
    end
  end
end
