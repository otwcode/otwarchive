require "spec_helper"

describe HitCountController do
  include RedirectExpectationHelper

  let(:work_id) { 42 }
  let(:ip) { "127.0.0.1" }

  before do
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(ip)
  end

  describe "POST #create" do
    it "doesn't perform any database queries" do
      expect(ActiveRecord::Base.connection).not_to receive(:exec_query)
      expect(ActiveRecord::Base.connection).not_to receive(:exec_update)
      expect(ActiveRecord::Base.connection).not_to receive(:exec_delete)

      post :create, params: { work_id: work_id, format: :json }
    end

    it "doesn't increment the hit count for bots" do
      expect(RedisHitCounter).not_to receive(:new)

      stub_const("ENV", Hash.new(ENV))
      ENV["REQUEST_FROM_BOT"] = "1"

      post :create, params: { work_id: work_id, format: :json }

      expect(response.body).to eq("")
      expect(response.status).to eq(403)
    end

    it "does increment the hit count for non-bots" do
      hit_counter = RedisHitCounter.new
      expect(RedisHitCounter).to receive(:new).and_return(hit_counter)
      expect(hit_counter).to receive(:add).with(work_id, ip)

      post :create, params: { work_id: work_id, format: :json }

      expect(response.body).to eq("")
      expect(response.status).to eq(200)
    end

    it "redirects to an error page on non-JSON requests" do
      post :create, params: { work_id: work_id }

      it_redirects_to_simple("/404")
    end
  end
end
