require "spec_helper"

describe HitCountController do
  describe "POST #create" do
    it "doesn't perform any database queries" do
      expect(ActiveRecord::Base.connection).not_to receive(:exec_query)
      expect(ActiveRecord::Base.connection).not_to receive(:exec_update)
      expect(ActiveRecord::Base.connection).not_to receive(:exec_delete)

      post :create, params: { work_id: 42, format: :json }
    end
  end
end
