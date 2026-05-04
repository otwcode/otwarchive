require "spec_helper"

describe "n+1 queries in the series controller" do
  include LoginMacros

  describe "#show", n_plus_one: true do
    let!(:user) { create(:user) }

    subject do
      proc do
        get series_path(Series.last)
      end
    end

    before do
      fake_login_known_user(user)
    end

    context "when all works are cached" do
      populate do |n|
        create(:series, works: create_list(:work, n))
        subject.call # this caches the blurbs
      end

      it "performs around 1 query per work" do
        # TODO: The last query is caused by Series#published_at and Series#revised_at and would be nice to eliminate as well
        expect do
          subject.call
          expect(response.body.scan('<li id="work_').size).to eq(current_scale.to_i)
        end.to perform_linear_number_of_queries(slope: 1)
      end
    end

    context "when nothing is cached" do
      populate do |n|
        create(:series, works: create_list(:work, n))
      end

      warmup { get series_path(create(:series)) }

      it "performs around 16 queries per work" do
        # TODO: Ideally, we'd like the uncached serial work listings to also have a
        # constant number of queries, instead of the linear number of queries
        # we're checking for here. But we also don't want to put too much
        # unnecessary load on the databases when we have a bunch of cache hits,
        # so this requires some care & tuning.
        expect do
          subject.call
          expect(response.body.scan('<li id="work_').size).to eq(current_scale.to_i)
        end.to perform_linear_number_of_queries(slope: 16)
      end
    end
  end
end
