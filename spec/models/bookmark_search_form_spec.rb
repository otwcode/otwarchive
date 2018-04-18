# frozen_string_literal: true

require "spec_helper"

describe BookmarkSearchForm do
  describe "options" do
    it "includes flags set to false" do
      bsf = BookmarkSearchForm.new(show_restricted: false, show_private: false)
      expect(bsf.options).to include(show_restricted: false)
      expect(bsf.options).to include(show_private: false)
    end
  end

  describe "bookmarkable_search_results" do
    describe "sorting" do
      let(:tag) { create(:canonical_fandom) }

      let!(:work1) do
        Delorean.time_travel_to 40.minutes.ago do
          create(:posted_work, title: "One", fandom_string: tag.name)
        end
      end

      let!(:work2) do
        Delorean.time_travel_to 60.minutes.ago do
          create(:posted_work, title: "Two", fandom_string: tag.name)
        end
      end

      let!(:work3) do
        Delorean.time_travel_to 50.minutes.ago do
          create(:posted_work, title: "Three", fandom_string: tag.name)
        end
      end

      let!(:bookmark1) do
        Delorean.time_travel_to 30.minutes.ago do
          create(:bookmark, bookmarkable: work1)
        end
      end

      let!(:bookmark2) do
        Delorean.time_travel_to 10.minutes.ago do
          create(:bookmark, bookmarkable: work2)
        end
      end

      let!(:bookmark3) do
        Delorean.time_travel_to 20.minutes.ago do
          create(:bookmark, bookmarkable: work3)
        end
      end

      before { run_all_indexing_jobs }

      context "by Date Updated" do
        it "returns bookmarkables in the correct order" do
          results = BookmarkSearchForm.new(
            parent: tag, sort_column: "bookmarkable_date"
          ).bookmarkable_search_results
          expect(results.map(&:title)).to eq ["One", "Three", "Two"]
        end

        it "changes when the work is updated" do
          work2.update_attribute(:revised_at, Time.now)
          run_all_indexing_jobs
          results = BookmarkSearchForm.new(
            parent: tag, sort_column: "bookmarkable_date"
          ).bookmarkable_search_results
          expect(results.map(&:title)).to eq ["Two", "One", "Three"]
        end
      end

      context "by Date Bookmarked" do
        it "returns bookmarkables in the correct order" do
          results = BookmarkSearchForm.new(
            parent: tag, sort_column: "created_at"
          ).bookmarkable_search_results
          expect(results.map(&:title)).to eq ["Two", "Three", "One"]
        end

        it "changes when a new bookmark is created" do
          create(:bookmark, bookmarkable: work1)
          run_all_indexing_jobs
          results = BookmarkSearchForm.new(
            parent: tag, sort_column: "created_at"
          ).bookmarkable_search_results
          expect(results.map(&:title)).to eq ["One", "Two", "Three"]
        end
      end
    end
  end
end
