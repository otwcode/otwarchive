require "spec_helper"

describe ResetBookmarkTagsJob do
  describe "#perform" do
    it "resets a non-canonical tag with no work uses" do
      # Create an official fandom and a "incorrect" tag (no works, but with type)
      fandom = create(:fandom, canonical: true)

      # Tag with incorrect type (Character) and no works - will be cleaned up
      dirty_tag = create(:tag,
                         name: "Dirty Tag",
                         type: "Character",
                         canonical: false,
                         taggings_count_cache: 0)

      # Valid association: Character can be a child of Fandom
      CommonTagging.create!(common_tag: dirty_tag, filterable: fandom)

      # Execute the job
      ResetBookmarkTagsJob.perform_now(Tag.pluck(:id))

      # Checks if the tag has been cleared (returned to "Tag" and lost the fandom)
      dirty_tag.reload
      expect(dirty_tag.type).to eq("Tag")
      expect(dirty_tag.common_taggings.count).to eq(0)
    end

    it "does not reset a non-canonical tag with work uses" do
      # Create an official fandom and a "legitimate" tag (with 5 works)
      fandom = create(:fandom, canonical: true)

      # Tag with correct type (Character) and 5 works - will not be cleaned up
      work_tag = create(:character,
                        name: "Work Tag",
                        type: "Character",
                        canonical: false,
                        taggings_count_cache: 5)

      CommonTagging.create!(common_tag: work_tag, filterable: fandom)

      # Execute the job
      ResetBookmarkTagsJob.perform_now(Tag.pluck(:id))

      # Checks if the tag has remained intact
      work_tag.reload
      expect(work_tag.common_taggings.count).to eq(1)
      expect(work_tag.type).to eq("Character")
    end

    it "does not reset a canonical tag" do
      # Create an official tag - will not be changed
      canonical_tag = create(:fandom,
                             name: "Official Fandom",
                             canonical: true)

      # Execute the job
      ResetBookmarkTagsJob.perform_now(Tag.pluck(:id))

      # Check if it is still official and has remained intact
      canonical_tag.reload
      expect(canonical_tag.canonical).to be_truthy
      expect(canonical_tag.type).to eq("Fandom")
    end
  end
end
