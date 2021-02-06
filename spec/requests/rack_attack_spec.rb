require "spec_helper"

describe "Rack::Attack", type: :request do
  # Our configuration ignores localhost by default, so we need to pick some other IP.
  let(:ip) { Faker::Internet.unique.ip_v4_address }

  before { freeze_time }

  context "on login attempts" do
    def unique_ip_env
      { "REMOTE_ADDR" => Faker::Internet.unique.ip_v4_address }
    end

    def unique_user_params
      { user: { login: Faker::Internet.unique.user_name, password: "secret" } }.to_query
    end

    it "throttles by IP" do
      env = { "REMOTE_ADDR" => ip }
      ArchiveConfig.RATE_LIMIT_LOGIN_ATTEMPTS.times do
        post user_session_path, params: unique_user_params, env: env
        expect(response).to have_http_status(:ok)
      end

      last_params = unique_user_params

      # The same IP is throttled.
      post user_session_path, params: last_params, env: env
      expect(response).to have_http_status(:too_many_requests)

      # A different IP is not.
      post user_session_path, params: last_params, env: unique_ip_env
      expect(response).to have_http_status(:ok)

      # The same IP is not throttled forever.
      travel ArchiveConfig.RATE_LIMIT_LOGIN_PERIOD.seconds
      post user_session_path, params: last_params, env: env
      expect(response).to have_http_status(:ok)
    end

    it "throttles by user name / email" do
      params = unique_user_params
      ArchiveConfig.RATE_LIMIT_LOGIN_ATTEMPTS.times do
        post user_session_path, params: params, env: unique_ip_env
        expect(response).to have_http_status(:ok)
      end

      last_env = unique_ip_env

      # The same user name is throttled.
      post user_session_path, params: params, env: last_env
      expect(response).to have_http_status(:too_many_requests)

      # A different user name is not.
      post user_session_path, params: unique_user_params, env: last_env
      expect(response).to have_http_status(:ok)

      # The same user name is not throttled forever.
      travel ArchiveConfig.RATE_LIMIT_LOGIN_PERIOD.seconds
      post user_session_path, params: params, env: last_env
      expect(response).to have_http_status(:ok)
    end
  end
end
