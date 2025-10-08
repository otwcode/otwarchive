require "spec_helper"

describe BookmarkableQuery do
  describe "#escape_restrictable_fields" do
    context "when restricted tags are shown" do
      let(:bookmark_query) { BookmarkQuery.new(show_restricted: true) }
      let(:query) { bookmark_query.bookmarkable_query }

      it "replaces 'tag' with 'general_tags'" do
        expect(query.escape_restrictable_fields("tag:foo")).to eq("general_tags:foo")
      end

      it "replaces 'public_tags' with 'general_tags'" do
        expect(query.escape_restrictable_fields("public_tags:foo")).to eq("general_tags:foo")
      end

      it "does not change 'general_tags'" do
        expect(query.escape_restrictable_fields("general_tags:foo")).to eq("general_tags:foo")
      end

      Tag::FILTERS.map(&:underscore).each do |tag_type|
        it "does not change 'general_#{tag_type}_ids'" do
          expect(query.escape_restrictable_fields("general_#{tag_type}_ids:foo")).to eq("general_#{tag_type}_ids:foo")
        end

        it "replaces 'public_#{tag_type}_ids' with 'general_#{tag_type}_ids'" do
          expect(query.escape_restrictable_fields("public_#{tag_type}_ids:foo")).to eq("general_#{tag_type}_ids:foo")
        end

        it "replaces '#{tag_type}_ids' with 'general_#{tag_type}_ids'" do
          expect(query.escape_restrictable_fields("#{tag_type}_ids:foo")).to eq("general_#{tag_type}_ids:foo")
        end
      end
    end

    context "when restricted tags are not shown" do
      let(:bookmark_query) { BookmarkQuery.new(show_restricted: false) }
      let(:query) { bookmark_query.bookmarkable_query }

      it "replaces 'tag' with 'public_tags'" do
        expect(query.escape_restrictable_fields("tag:foo")).to eq("public_tags:foo")
      end

      it "replaces 'general_tags' with 'public_tags'" do
        expect(query.escape_restrictable_fields("general_tags:foo")).to eq("public_tags:foo")
      end

      it "does not change 'public_tags'" do
        expect(query.escape_restrictable_fields("public_tags:foo")).to eq("public_tags:foo")
      end

      Tag::FILTERS.map(&:underscore).each do |tag_type|
        it "does not change 'public_#{tag_type}_ids'" do
          expect(query.escape_restrictable_fields("public_#{tag_type}_ids:foo")).to eq("public_#{tag_type}_ids:foo")
        end

        it "replaces 'general_#{tag_type}_ids' with 'public_#{tag_type}_ids'" do
          expect(query.escape_restrictable_fields("general_#{tag_type}_ids:foo")).to eq("public_#{tag_type}_ids:foo")
        end

        it "replaces '#{tag_type}_ids' with 'public_#{tag_type}_ids'" do
          expect(query.escape_restrictable_fields("#{tag_type}_ids:foo")).to eq("public_#{tag_type}_ids:foo")
        end
      end
    end
  end

  describe "#generated_query" do
    describe "a blank query" do
      let(:bookmark_query) { BookmarkQuery.new }
      let(:bookmarkable_query) { bookmark_query.bookmarkable_query }

      it "excludes hidden, draft, and restricted bookmarkables when logged out" do
        excluded = bookmarkable_query.generated_query.dig(:query, :bool, :must_not)
        expect(excluded).to include(term: { hidden_by_admin: "true" })
        expect(excluded).to include(term: { posted: "false" })
        expect(excluded).to include(term: { restricted: "true" })
      end

      it "excludes hidden and draft bookmarkables, but not restricted when logged in" do
        User.current_user = build_stubbed(:user)

        excluded = bookmarkable_query.generated_query.dig(:query, :bool, :must_not)
        expect(excluded).to include(term: { hidden_by_admin: "true" })
        expect(excluded).to include(term: { posted: "false" })
        expect(excluded).not_to include(term: { restricted: "true" })
      end

      it "excludes private and hidden bookmarks" do
        child_filter = bookmarkable_query.generated_query.dig(:query, :bool, :must)

        expect(child_filter.dig(:has_child, :query, :bool, :filter)).to include(term: { hidden_by_admin: "false" })
        expect(child_filter.dig(:has_child, :query, :bool, :filter)).to include(term: { private: "false" })
      end

      it "doesn't include aggregations" do
        aggregations = bookmarkable_query.generated_query[:aggs]
        expect(aggregations).to be_blank
      end
    end

    describe "a faceted query" do
      let(:bookmark_query) { BookmarkQuery.new(faceted: true) }
      let(:bookmarkable_query) { bookmark_query.bookmarkable_query }
      let(:aggregations) { bookmarkable_query.generated_query[:aggs] }

      context "when run by a logged-in user" do
        before do
          User.current_user = create(:user)
        end

        Tag::FILTERS.each do |type|
          it "includes #{type.underscore.humanize.downcase} aggregations" do
            expect(aggregations[type.underscore]).to \
              include({ terms: { field: "general_#{type.underscore}_ids" } })
          end
        end
      end

      context "when run by a logged-in admin" do
        before do
          User.current_user = create(:admin)
        end

        Tag::FILTERS.each do |type|
          it "includes #{type.underscore.humanize.downcase} aggregations" do
            expect(aggregations[type.underscore]).to \
              include({ terms: { field: "general_#{type.underscore}_ids" } })
          end
        end
      end

      context "when run by a guest" do
        Tag::FILTERS.each do |type|
          it "includes #{type.underscore.humanize.downcase} aggregations" do
            expect(aggregations[type.underscore]).to \
              include({ terms: { field: "public_#{type.underscore}_ids" } })
          end
        end
      end

      it "includes aggregations for the bookmark tags" do
        # Top-level aggregation to get all children:
        expect(aggregations[:bookmarks]).to \
          include({ children: { type: "bookmark" } })

        # Nested aggregation to filter the children:
        expect(aggregations.dig(:bookmarks, :aggs, :filtered_bookmarks)).to \
          include({ filter: bookmarkable_query.bookmark_bool })

        # Nest even further to get the tags of the children:
        expect(aggregations.dig(:bookmarks, :aggs, :filtered_bookmarks, :aggs, :tag)).to \
          include({ terms: { field: "tag_ids" } })
      end
    end

    it "combines all bookmark filters (positive and negative) in a single has_child query" do
      bookmark_query = BookmarkQuery.new(user_ids: [5], excluded_bookmark_tag_ids: [666])
      q = bookmark_query.bookmarkable_query
      child_filter = q.generated_query.dig(:query, :bool, :must)
      expect(child_filter.dig(:has_child, :query, :bool, :filter)).to include(term: { private: "false" })
      expect(child_filter.dig(:has_child, :query, :bool, :filter)).to include(term: { user_id: 5 })
      expect(child_filter.dig(:has_child, :query, :bool, :must_not)).to include(terms: { tag_ids: [666] })
    end

    context "when querying as a user" do
      before do
        User.current_user = create(:user)
      end

      it "converts the 'tag' field to 'general_tags'" do
        bookmark_query = BookmarkQuery.new(bookmarkable_query: "tag:foo")
        q = bookmark_query.bookmarkable_query.generated_query
        filter_string = q[:query][:bool][:filter][0][:query_string][:query]
        expect(filter_string).to eq("general_tags:foo")
      end

      it "converts the 'tags' field to 'general_tags'" do
        bookmark_query = BookmarkQuery.new(bookmarkable_query: "tags:foo")
        q = bookmark_query.bookmarkable_query.generated_query
        filter_string = q[:query][:bool][:filter][0][:query_string][:query]
        expect(filter_string).to eq("general_tags:foo")
      end

      %w[archive_warning category character fandom filter freeform rating relationship tags].each do |field|
        it "converts the '#{field}' field to 'general_#{field}'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "#{field}:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("general_#{field}:foo")
        end

        it "converts the 'public_#{field}' field to 'general_#{field}'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "public_#{field}:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("general_#{field}:foo")
        end

        it "converts the '#{field}_ids' field to 'general_#{field}_ids'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "#{field}_ids:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("general_#{field}_ids:foo")
        end

        it "converts the 'public_#{field}_ids' field to 'general_#{field}_ids'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "public_#{field}_ids:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("general_#{field}_ids:foo")
        end
      end
    end

    context "when querying as an admin" do
      before do
        User.current_user = create(:admin)
      end

      it "converts the 'tag' field to 'general_tags'" do
        bookmark_query = BookmarkQuery.new(bookmarkable_query: "tag:foo")
        q = bookmark_query.bookmarkable_query.generated_query
        filter_string = q[:query][:bool][:filter][0][:query_string][:query]
        expect(filter_string).to eq("general_tags:foo")
      end

      it "converts the 'tags' field to 'general_tags'" do
        bookmark_query = BookmarkQuery.new(bookmarkable_query: "tags:foo")
        q = bookmark_query.bookmarkable_query.generated_query
        filter_string = q[:query][:bool][:filter][0][:query_string][:query]
        expect(filter_string).to eq("general_tags:foo")
      end

      %w[archive_warning category character fandom filter freeform rating relationship tags].each do |field|
        it "converts the '#{field}' field to 'general_#{field}'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "#{field}:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("general_#{field}:foo")
        end

        it "converts the 'public_#{field}' field to 'general_#{field}'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "public_#{field}:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("general_#{field}:foo")
        end

        it "converts the '#{field}_ids' field to 'general_#{field}_ids'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "#{field}_ids:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("general_#{field}_ids:foo")
        end

        it "converts the 'public_#{field}_ids' field to 'general_#{field}_ids'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "public_#{field}_ids:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("general_#{field}_ids:foo")
        end
      end
    end

    context "when querying as a guest" do
      it "converts the 'tag' field to 'public_tags'" do
        bookmark_query = BookmarkQuery.new(bookmarkable_query: "tag:foo")
        q = bookmark_query.bookmarkable_query.generated_query
        filter_string = q[:query][:bool][:filter][0][:query_string][:query]
        expect(filter_string).to eq("public_tags:foo")
      end

      it "converts the 'tags' field to 'public_tags'" do
        bookmark_query = BookmarkQuery.new(bookmarkable_query: "tags:foo")
        q = bookmark_query.bookmarkable_query.generated_query
        filter_string = q[:query][:bool][:filter][0][:query_string][:query]
        expect(filter_string).to eq("public_tags:foo")
      end

      %w[archive_warning category character fandom filter freeform rating relationship tags].each do |field|
        it "converts the '#{field}' field to 'public_#{field}'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "#{field}:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("public_#{field}:foo")
        end

        it "converts the 'general_#{field}' field to 'public_#{field}'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "general_#{field}:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("public_#{field}:foo")
        end

        it "converts the '#{field}_ids' field to 'public_#{field}_ids'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "#{field}_ids:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("public_#{field}_ids:foo")
        end

        it "converts the 'general_#{field}_ids' field to 'public_#{field}_ids'" do
          bookmark_query = BookmarkQuery.new(bookmarkable_query: "general_#{field}_ids:foo")
          q = bookmark_query.bookmarkable_query.generated_query
          filter_string = q[:query][:bool][:filter][0][:query_string][:query]
          expect(filter_string).to eq("public_#{field}_ids:foo")
        end
      end
    end
  end
end
