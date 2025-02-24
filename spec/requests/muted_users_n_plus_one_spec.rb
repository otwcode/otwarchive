# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the muted users controller" do
  include LoginMacros

  describe "#index", n_plus_one: true do
    context "with a logged in user who has muted someone" do
      let!(:muter) { create(:user) }

      populate do |n|
        muted_users = create_list(:user, n)
        muted_users.each do |muted|
          # TODO: Rails doesn't seem to want to include all variants for default_pseud when using .processed.url for the icon, so this won't work right now.
          # This tests passes when using rails_blob_url (proxying)
          # muted.default_pseud.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
          Mute.create(muter: muter, muted: muted)
        end
      end

      before do
        fake_login_known_user(muter)
      end

      subject do
        proc do
          get user_muted_users_path(user_id: muter)
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
