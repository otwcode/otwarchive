# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the skins controller" do
  include LoginMacros

  shared_examples "produces a constant number of queries" do
    warmup { subject.call }

    it "produces a constant number of queries" do
      expect { subject.call }
        .to perform_constant_number_of_queries
    end
  end

  describe "#index", n_plus_one: true do
    context "when displaying a user's work skins" do
      let!(:user) { create(:user) }

      populate do |n|
        create_list(:work_skin, n, :private, author: user).each do |skin|
          skin.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
        end
      end

      subject do
        proc do
          get user_skins_path(user_id: user), params: { "skin_type" => "WorkSkin" }
        end
      end

      before do
        fake_login_known_user(user)
      end

      it_behaves_like "produces a constant number of queries"
    end

    context "when displaying a user's site skins" do
      let!(:user) { create(:user) }

      populate do |n|
        create_list(:skin, n, author: user).each do |skin|
          skin.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
        end
      end

      subject do
        proc do
          get user_skins_path(user_id: user), params: { "skin_type" => "Site" }
        end
      end

      before do
        fake_login_known_user(user)
      end

      it_behaves_like "produces a constant number of queries"
    end

    context "when displaying public work skins" do
      populate do |n|
        create_list(:work_skin, n, :public).each do |skin|
          skin.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
        end
      end

      subject do
        proc do
          get skins_path, params: { "skin_type" => "WorkSkin" }
        end
      end

      it_behaves_like "produces a constant number of queries"
    end

    context "when displaying public site skins" do
      populate do |n|
        create_list(:skin, n, :public).each do |skin|
          skin.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
        end
      end

      subject do
        proc do
          2.times { get skins_path, params: { "skin_type" => "Site" } }
          #         binding.pry
        end
      end

      it_behaves_like "produces a constant number of queries"
    end
  end
end