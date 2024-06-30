# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the skins controller" do
  include LoginMacros

  describe "#index", n_plus_one: true do
    context "when displaying a user's work skins" do
      let!(:user) { create(:user) }

      populate do |n|
        create_list(:work_skin, n, :private, author: user)
      end

      subject do
        proc do
          get user_skins_path(user_id: user), params: { "skin_type" => "WorkSkin" }
        end
      end

      before do
        fake_login_known_user(user)
      end

      warmup { subject.call }

      it "produces a constant number of queries" do
        expect { subject.call }
          .to perform_constant_number_of_queries
      end
    end

    context "when displaying a user's site skins" do
      let!(:user) { create(:user) }

      populate do |n|
        create_list(:skin, n, author: user)
      end

      subject do
        proc do
          get user_skins_path(user_id: user), params: { "skin_type" => "Site" }
        end
      end

      before do
        fake_login_known_user(user)
      end

      warmup { subject.call }

      it "produces a constant number of queries" do
        expect { subject.call }
          .to perform_constant_number_of_queries
      end
    end

    context "when displaying public work skins" do
      populate do |n|
        create_list(:work_skin, n, :public)
      end

      subject do
        proc do
          get skins_path, params: { "skin_type" => "WorkSkin" }
        end
      end

      warmup { subject.call }

      it "produces a constant number of queries" do
        expect { subject.call }
          .to perform_constant_number_of_queries
      end
    end

    context "when displaying public site skins" do
      populate do |n|
        create_list(:skin, n, :public)
      end

      subject do
        proc do
          get skins_path, params: { "skin_type" => "Site" }
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
