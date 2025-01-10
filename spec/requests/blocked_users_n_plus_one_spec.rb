# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the blocked users controller" do
  include LoginMacros

  describe "#index", n_plus_one: true do
    context "with a logged in user who has blocked someone" do
      let!(:blocker) { create(:user) }

      populate do |n|
        blocked_users = create_list(:user, n)
        blocked_users.each do |blocked|
          # Rails doesn't seem to want to include variants, so this won't work right now.
          # We can revisit when https://github.com/rails/rails/pull/49231 is released OR we upgrade to Rails 7.1
          # blocked.default_pseud.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
          Block.create(blocker: blocker, blocked: blocked)
        end
      end

      before do
        fake_login_known_user(blocker)
      end

      subject do
        proc do
          get user_blocked_users_path(user_id: blocker)
        end
      end

      warmup { subject.call }

      it "produces a constant number of queries" do
        expect { subject.call }
          .to perform_constant_number_of_queries
      end
    end
  end
end
