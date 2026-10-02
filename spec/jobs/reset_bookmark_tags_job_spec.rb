require "spec_helper"

describe ResetBookmarkTagsJob do
  describe "#perform" do
    it "resets a non-canonical tag with no work uses" do
      fandom = create(:fandom, canonical: true)

      dirty_tag = create(:tag,
                         name: "Dirty Tag",
                         type: "Character",
                         canonical: false,
                         taggings_count_cache: 1)

      CommonTagging.create!(common_tag: dirty_tag, filterable: fandom)
      ResetBookmarkTagsJob.perform_now([dirty_tag.id])

      dirty_tag.reload
      expect(dirty_tag.type).to eq("UnsortedTag")
      expect(dirty_tag.common_taggings.count).to eq(0)
    end

    it "does not reset a non-canonical tag with work uses" do
      fandom = create(:fandom, canonical: true)

      work_tag = create(:character,
                        name: "Work Tag",
                        type: "Character",
                        canonical: false,
                        taggings_count_cache: 5)

      CommonTagging.create!(common_tag: work_tag, filterable: fandom)
      work = create(:work)
      create(:tagging, tagger: work_tag, taggable: work)
      ResetBookmarkTagsJob.perform_now([work_tag.id])

      work_tag.reload
      expect(work_tag.common_taggings.count).to eq(1)
      expect(work_tag.type).to eq("Character")
    end

    it "does not reset a canonical tag" do
      canonical_tag = create(:fandom,
                             name: "Official Fandom",
                             canonical: true)

      ResetBookmarkTagsJob.perform_now([canonical_tag.id])

      canonical_tag.reload
      expect(canonical_tag.canonical).to be_truthy
      expect(canonical_tag.type).to eq("Fandom")
    end
  end
end
