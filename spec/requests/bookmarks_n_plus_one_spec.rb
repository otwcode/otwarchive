require "spec_helper"

describe "n+1 queries in the bookmarks controller" do
  include LoginMacros

  shared_examples "displaying multiple bookmarks efficiently" do
    context "when all bookmarks are cached", :n_plus_one do
      populate do |n|
        create_list(:bookmark, n)
        subject.call
      end

      it "performs a constant number of queries" do
        expect do
          subject.call
          expect(response.body.scan('<li id="bookmark_').size).to eq(current_scale.to_i)
        end.to perform_constant_number_of_queries
      end
    end

    context "when no bookmarks are cached", :n_plus_one do
      populate do |n|
        create_list(:bookmark, n)
      end

      it "performs around 15 queries per bookmark" do
        # TODO: Ideally, we'd like the uncached bookmark listings to also have a
        # constant number of queries, instead of the linear number of queries
        # we're checking for here. But we also don't want to put too much
        # unnecessary load on the databases when we have a bunch of cache hits,
        # so this requires some care & tuning.
        expect do
          subject.call
          expect(response.body.scan('<li id="bookmark_').size).to eq(current_scale.to_i)
        end.to perform_linear_number_of_queries(slope: 15).with_warming_up
      end
    end
  end

  describe "#index" do
    context "when viewing recent bookmarks" do
      subject do
        proc do
          get bookmarks_path
        end
      end

      context "when logged out" do
        it_behaves_like "displaying multiple bookmarks efficiently"
      end
    end

    context "when viewing a user's bookmarks" do
      subject do
        proc do
          get user_bookmarks_path(user_id: "bookmarker")
        end
      end

      context "when all bookmarks are cached", :n_plus_one do
        populate do |n|
          BookmarkIndexer.prepare_for_testing
          bookmarker = create(:user, login: "bookmarker")
          create_list(:bookmark, n, pseud_id: bookmarker.default_pseud.id)
          run_all_indexing_jobs
          subject.call
        end

        it "performs a constant number of queries" do
          expect do
            subject.call
            expect(response.body.scan('<li id="bookmark_').size)
              .to eq(current_scale.to_i)
          end.to perform_constant_number_of_queries
        end
      end

      context "when no bookmarks are cached", :n_plus_one do
        populate do |n|
          BookmarkIndexer.prepare_for_testing
          bookmarker = create(:user, login: "bookmarker")
          create_list(:bookmark, n, pseud_id: bookmarker.default_pseud.id)
          run_all_indexing_jobs
        end

        it "performs around 11 queries per bookmark" do
          expect do
            subject.call
            expect(response.body.scan('<li id="bookmark_').size)
              .to eq(current_scale.to_i)
          end.to perform_linear_number_of_queries(slope: 11).with_warming_up
        end
      end
    end

    context "when viewing bookmarks under a tag" do
      subject do
        proc do
          get tag_bookmarks_path(tag_id: "Bookmarked Fandom")
        end
      end

      context "when all bookmarks are cached", :n_plus_one do
        populate do |n|
          WorkIndexer.prepare_for_testing
          BookmarkIndexer.prepare_for_testing
          fandom = create(:canonical_fandom, name: "Bookmarked Fandom")
          n.times do
            work = create(:work, fandom_string: fandom.name)
            create(:bookmark, bookmarkable_id: work.id)
          end
          run_all_indexing_jobs
          subject.call
        end

        it "performs a constant number of queries" do
          expect do
            subject.call
            expect(response.body.scan('<li id="bookmark_').size)
              .to eq(current_scale.to_i)
          end.to perform_constant_number_of_queries
        end
      end

      context "when no bookmarks are cached", :n_plus_one do
        populate do |n|
          WorkIndexer.prepare_for_testing
          BookmarkIndexer.prepare_for_testing
          fandom = create(:canonical_fandom, name: "Bookmarked Fandom")
          n.times do
            work = create(:work, fandom_string: fandom.name)
            create(:bookmark, bookmarkable_id: work.id)
          end
          run_all_indexing_jobs
        end

        it "performs around 11 queries per bookmark" do
          expect do
            subject.call
            expect(response.body.scan('<li id="bookmark_').size)
              .to eq(current_scale.to_i)
          end.to perform_linear_number_of_queries(slope: 11).with_warming_up
        end
      end
    end
  end
end
