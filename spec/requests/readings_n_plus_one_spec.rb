require "spec_helper"

describe "n+1 queries in the readings controller" do
  include LoginMacros

  describe "#index", n_plus_one: true do
    context "when displaying a user's reading history" do
      let!(:user) { create(:user) }

      subject do
        proc do
          get user_readings_path(user)
        end
      end

      before do
        fake_login_known_user(user)
      end

      context "when all works are cached" do
        populate do |n|
          create_list(:reading, n, user: user)
          subject.call # this caches the blurbs
        end

        it "produces a constant number of queries" do
          expect do
            subject.call
            expect(response.body.scan('<li id="work_').size).to eq(current_scale.to_i)
          end.to perform_constant_number_of_queries
        end
      end

      context "when nothing is cached" do
        populate do |n|
          create_list(:reading, n, user: user)
        end

        it "performs around 12 queries per reading" do
          # TODO: Ideally, we'd like the uncached reading listings to also have a
          # constant number of queries, instead of the linear number of queries
          # we're checking for here. But we also don't want to put too much
          # unnecessary load on the databases when we have a bunch of cache hits,
          # so this requires some care & tuning.
          expect do
            subject.call
            expect(response.body.scan('<li id="work_').size).to eq(current_scale.to_i)
          end.to perform_linear_number_of_queries(slope: 12).with_warming_up
        end
      end
    end
  end
end
