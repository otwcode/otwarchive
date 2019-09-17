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

    describe "searching" do
      let(:language) { create(:language, short: "nl") }

      let(:work1) { create(:posted_work, language_id: Language.default.id) }
      let(:work2) { create(:posted_work, language_id: language.id) }

      let!(:bookmark1) { create(:bookmark, bookmarkable: work1) }
      let!(:bookmark2) { create(:bookmark, bookmarkable: work2) }

      before { run_all_indexing_jobs }

      context "by work language" do
        let(:unused_language) { create(:language, short: "tlh") }

        it "returns work bookmarkables with specified language" do
          # "Work language" dropdown, with short names
          results = BookmarkSearchForm.new(language_id: "nl").bookmarkable_search_results
          expect(results).not_to include work1
          expect(results).to include work2

          # "Work language" dropdown, with IDs (backward compatibility)
          bsf = BookmarkSearchForm.new(language_id: language.id)
          expect(bsf.language_id).to eq("nl")
          results = bsf.bookmarkable_search_results
          expect(results).not_to include work1
          expect(results).to include work2

          # "Any field on work" or "Search within results", with short names
          results = BookmarkSearchForm.new(bookmarkable_query: "language_id: nl").bookmarkable_search_results
          expect(results).not_to include work1
          expect(results).to include work2

          # "Any field on work" or "Search within results", with IDs (backward compatibility)
          bsf = BookmarkSearchForm.new(bookmarkable_query: "language_id: #{language.id} OR language_id: #{unused_language.id}")
          expect(bsf.bookmarkable_query).to eq("language_id: nl OR language_id: tlh")
          results = bsf.bookmarkable_search_results
          expect(results).not_to include work1
          expect(results).to include work2
        end
      end
    end
  end

  describe "when searching by bookmarker" do
    let(:bookmarker) { create(:user, login: "yabalchoath") }

    {
      Work: :posted_work,
      Series: :series_with_a_work,
      ExternalWork: :external_work
    }.each_pair do |type, factory|
      it "returns the correct bookmarked #{type.to_s.pluralize} when bookmarker changes username" do
        bookmarkable = create(factory)
        bookmark = create(:bookmark,
                          bookmarkable_id: bookmarkable.id,
                          bookmarkable_type: type,
                          pseud: bookmarker.default_pseud)
        run_all_indexing_jobs

        result = BookmarkSearchForm.new(bookmarker: "yabalchoath").search_results.first
        expect(result).to eq bookmark

        bookmarker.login = "cioelle"
        bookmarker.save!
        run_all_indexing_jobs

        result = BookmarkSearchForm.new(bookmarker: "yabalchoath").search_results.first
        expect(result).to be_nil
        result = BookmarkSearchForm.new(bookmarker: "cioelle").search_results.first
        expect(result).to eq bookmark
      end
    end
  end

  describe "when searching any bookmarkable field for author of bookmarkable" do
    let(:author) { create(:user, login: "yabalchoath") }

    {
      Work: :posted_work,
      Series: :series_with_a_work
    }.each_pair do |type, factory|
      it "returns the correct bookmarked #{type.to_s.pluralize} when author changes username" do
        bookmarkable = create(factory, authors: [author.default_pseud])
        bookmark = create(:bookmark, bookmarkable_id: bookmarkable.id, bookmarkable_type: type)
        run_all_indexing_jobs

        result = BookmarkSearchForm.new(bookmarkable_query: "yabalchoath").search_results.first
        expect(result).to eq bookmark

        author.login = "cioelle"
        author.save!
        run_all_indexing_jobs

        result = BookmarkSearchForm.new(bookmarkable_query: "yabalchoath").search_results.first
        expect(result).to be_nil
        result = BookmarkSearchForm.new(bookmarkable_query: "cioelle").search_results.first
        expect(result).to eq bookmark
      end
    end
  end

  describe "#processed_options" do
    it "removes blank options" do
      options = { foo: nil, bar: false }
      searcher = BookmarkSearchForm.new(options)
      expect(searcher.options).to have_key(:bar)
      expect(searcher.options).not_to have_key(:foo)
    end

    it "renames the notes field" do
      options = { bookmark_notes: "Mordor" }
      searcher = BookmarkSearchForm.new(options)
      expect(searcher.options[:notes]).to eq("Mordor")
    end

    it "unescapes angle brackets for date fields" do
      options = {
        date: "&lt;1 week ago",
        bookmarkable_date: "&gt;1 year ago",
        title: "escaped &gt;.&lt; field"
      }
      searcher = BookmarkSearchForm.new(options)
      expect(searcher.options[:date]).to eq("<1 week ago")
      expect(searcher.options[:bookmarkable_date]).to eq(">1 year ago")
      expect(searcher.options[:title]).to eq("escaped &gt;.&lt; field")
    end

    it "renames old warning_ids fields" do
      options = { warning_ids: [13] }
      searcher = BookmarkSearchForm.new(options)
      expect(searcher.options[:archive_warning_ids]).to eq([13])
    end
  end
end
