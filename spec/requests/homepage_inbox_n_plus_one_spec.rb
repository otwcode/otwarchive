require "spec_helper"

describe "n+1 queries in the inbox controller for the homepage" do
  include LoginMacros

  describe "#index", n_plus_one: true do
    context "when displaying a user's unread messages on the homepage" do
      let!(:user) { create(:user) }

      subject do
        proc do
          get "/"
        end
      end

      before do
        fake_login_known_user(user)
      end

      context "when all works are cached" do
        populate do |n|
          create_list(:inbox_comment, n)
          subject.call # this caches the comments
        end

        it "produces a constant number of queries" do
          expect { subject.call }
            .to perform_constant_number_of_queries
        end
      end

      context "when nothing is cached" do
        populate do |n|
          create_list(:inbox_comment, n)
        end

        it "performs around 9 queries per message" do
          # TODO: Ideally, we'd like the uncached inbox listings to also have a
          # constant number of queries, instead of the linear number of queries
          # we're checking for here. But we also don't want to put too much
          # unnecessary load on the databases when we have a bunch of cache hits,
          # so this requires some care & tuning.
          expect { subject.call }
            .to perform_linear_number_of_queries(slope: 9).with_warming_up
        end
      end
    end
  end
end
