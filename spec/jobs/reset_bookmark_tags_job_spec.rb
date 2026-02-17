require "spec_helper"

describe ResetBookmarkTagsJob do
  describe "#perform" do
    it "should reset invalid bookmarks and ignore legitimate ones" do
      # 1. Scenario: An "incorrect" tag - incorrect type, with kinship, without works - should NEVER be changed.
      # It should revert to "Tag", with associations removed
      fandom = create(:fandom, canonical: true)

      # Tag with incorrect type (Character) and no works - will be cleaned up
      dirty_tag = create(:tag,
                         name: "Dirty Tag",
                         type: "Character",
                         canonical: false,
                         taggings_count_cache: 0)

      # Valid association: Character can be a child of Fandom
      CommonTagging.create!(common_tag: dirty_tag, filterable: fandom)

      # 2. Scenario: Legitimate tag - has works, should NOT be changed
      work_tag = create(:character,
                        name: "Work Tag",
                        type: "Character",
                        canonical: false,
                        taggings_count_cache: 5) # has work, not within scope

      CommonTagging.create!(common_tag: work_tag, filterable: fandom)

      # 3. Scenario: Canonical tag - should NEVER be changed
      canonical_tag = create(:fandom,
                             name: "Official Fandom",
                             canonical: true)

      # Executing the job
      ResetBookmarkTagsJob.perform_now

      # Checks
      # Incorrect tag: should revert to generic tag and lose associations
      dirty_tag.reload
      expect(dirty_tag.type).to eq("Tag")
      expect(dirty_tag.common_taggings.count).to eq(0)

      # Tag with works: nothing changes
      work_tag.reload
      expect(work_tag.common_taggings.count).to eq(1)

      # Canonical tag: remains canonical
      canonical_tag.reload
      expect(canonical_tag.canonical).to be_truthy
    end
  end
end
