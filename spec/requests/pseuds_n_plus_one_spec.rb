# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the user pseuds controller" do
  include LoginMacros

  describe "#index", n_plus_one: true do
    let!(:user) { create(:user) }

    populate do |n|
      create_list(:pseud, n, user: user).each do |pseud|
        pseud.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
      end
    end

    before do
      fake_login_known_user(user)
    end

    subject do
      proc do
        get user_pseuds_path(user_id: user)
      end
    end

    warmup { subject.call }

    # TODO: https://otwarchive.atlassian.net/browse/AO3-6738
    xit "produces a constant number of queries" do
      expect { subject.call }
        .to perform_constant_number_of_queries
    end
  end
end
