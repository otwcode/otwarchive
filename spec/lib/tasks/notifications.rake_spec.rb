require "spec_helper"

describe "rake notifications:send_tos_update" do
  include ActiveJob::TestHelper

  let(:admin_post) { create(:admin_post) }

  context "with one user" do
    let!(:user) { create(:user) }

    it "enqueues one tos update notifications" do
      expect(User.all.size).to eq(1)
      expect { subject.invoke(admin_post.id) }
        .to have_enqueued_mail(TosUpdateMailer, :tos_update_notification).on_queue(:tos_update).with(user, admin_post.id)
    end
  end

  context "with multiple users" do
    before { create_list(:user, 10) }

    it "enqueues multiple tos update notifications" do
      expect(User.all.size).to eq(10)
      expect { subject.invoke(admin_post.id) }
        .to have_enqueued_mail(TosUpdateMailer, :tos_update_notification).on_queue(:tos_update).with(instance_of(User), admin_post.id).exactly(10)
    end
  end
end
