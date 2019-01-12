# frozen_string_literal: true

require "spec_helper"

describe TagQuery do
  context "searching tags by draft status" do
    let!(:work) do
      create(:posted_work,
             fandom_string: "jjba,imas",
             character_string: "bruno,koume",
             relationship_string: "bruabba,koume/ryo",
             freeform_string: "slice of life,horror")
    end

    let!(:draft) do
      create(:draft,
             fandom_string: "zombie land saga,imas",
             character_string: "saki,koume",
             relationship_string: "saki/ai,koume/ryo",
             freeform_string: "action,horror")
    end

    before { run_all_indexing_jobs }

    it "includes tags used only in drafts" do
      results = TagQuery.new(type: "Fandom", draft_only: true).search_results.map(&:name)
      expect(results).to contain_exactly("zombie land saga")

      results = TagQuery.new(type: "Character", draft_only: true).search_results.map(&:name)
      expect(results).to contain_exactly("saki")

      results = TagQuery.new(type: "Relationship", draft_only: true).search_results.map(&:name)
      expect(results).to contain_exactly("saki/ai")

      results = TagQuery.new(type: "Freeform", draft_only: true).search_results.map(&:name)
      expect(results).to contain_exactly("action")

      # draft-only tags appear on another posted work
      create(:posted_work,
             fandom_string: "zombie land saga",
             character_string: "saki",
             relationship_string: "saki/ai",
             freeform_string: "action")
      run_all_indexing_jobs

      expect(TagQuery.new(type: "Fandom", draft_only: true).search_results).to be_empty
      expect(TagQuery.new(type: "Character", draft_only: true).search_results).to be_empty
      expect(TagQuery.new(type: "Relationship", draft_only: true).search_results).to be_empty
      expect(TagQuery.new(type: "Freeform", draft_only: true).search_results).to be_empty
    end

    it "excludes tags used only in drafts" do
      results = TagQuery.new(type: "Fandom", draft_only: false).search_results.map(&:name)
      expect(results).to contain_exactly("jjba", "imas")

      results = TagQuery.new(type: "Character", draft_only: false).search_results.map(&:name)
      expect(results).to contain_exactly("bruno", "koume")

      results = TagQuery.new(type: "Relationship", draft_only: false).search_results.map(&:name)
      expect(results).to contain_exactly("bruabba", "koume/ryo")

      results = TagQuery.new(type: "Freeform", draft_only: false).search_results.map(&:name)
      expect(results).to contain_exactly("slice of life", "horror")

      # draft gets posted
      draft.update_attributes(posted: true)
      run_all_indexing_jobs

      results = TagQuery.new(type: "Fandom", draft_only: false).search_results.map(&:name)
      expect(results).to contain_exactly("zombie land saga", "jjba", "imas")

      results = TagQuery.new(type: "Character", draft_only: false).search_results.map(&:name)
      expect(results).to contain_exactly("saki", "bruno", "koume")

      results = TagQuery.new(type: "Relationship", draft_only: false).search_results.map(&:name)
      expect(results).to contain_exactly("saki/ai", "bruabba", "koume/ryo")

      results = TagQuery.new(type: "Freeform", draft_only: false).search_results.map(&:name)
      expect(results).to contain_exactly("action", "slice of life", "horror")
    end

    it "returns all tags, drafts or not" do
      results = TagQuery.new(type: "Fandom").search_results.map(&:name)
      expect(results).to contain_exactly("zombie land saga", "jjba", "imas")

      results = TagQuery.new(type: "Character").search_results.map(&:name)
      expect(results).to contain_exactly("saki", "bruno", "koume")

      results = TagQuery.new(type: "Relationship").search_results.map(&:name)
      expect(results).to contain_exactly("saki/ai", "bruabba", "koume/ryo")

      results = TagQuery.new(type: "Freeform").search_results.map(&:name)
      expect(results).to contain_exactly("action", "slice of life", "horror")
    end
  end
end
