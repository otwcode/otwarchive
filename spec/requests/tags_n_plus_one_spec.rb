require "spec_helper"

describe "n+1 queries in the tags controller" do
  describe "#feed", n_plus_one: true do
    context "when creating a tag's feed" do
      let!(:tag) { create(:canonical_fandom, name: "Hermitcraft SMP") }

      subject do
        proc do
          get feed_tag_path({ id: tag.id, format: :atom })
        end
      end

      context "when all bylines are cached" do
        populate do |n|
          create_list(:work, n, fandom_string: "Hermitcraft SMP")
          subject.call # this caches the bylines
        end

        it "produces a constant number of queries" do
          expect do
            subject.call
            expect(response.body.scan("<author>").size).to eq(current_scale.to_i)
          end.to perform_constant_number_of_queries
        end
      end

      context "when nothing is cached" do
        populate do |n|
          create_list(:work, n, fandom_string: "Hermitcraft SMP")
        end

        it "performs around 4 queries per work" do
          # TODO: Ideally, we'd like the uncached tag feed to also have a
          # constant number of queries, instead of the linear number of queries
          # we're checking for here. But we also don't want to put too much
          # unnecessary load on the databases when we have a bunch of cache hits,
          # so this requires some care & tuning.
          expect do
            subject.call
            expect(response.body.scan("<author>").size).to eq(current_scale.to_i)
          end.to perform_linear_number_of_queries(slope: 4).with_warming_up
        end
      end
    end
  end
end
