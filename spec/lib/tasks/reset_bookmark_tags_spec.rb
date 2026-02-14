require "spec_helper"
require "rake"

describe "Reset bookmark tags task" do
  before(:all) do
    Rake.application.rake_require "tasks/reset_bookmark_tags"
    Rake::Task.define_task(:environment)
  end

  let(:task_name) { "tags:reset_bookmark_only" }
  let(:rake_task) { Rake::Task[task_name] }

  it "should reset invalid bookmarks and ignore legitimate ones" do
    # 1. Scenario: An "incorrect" tag - incorrect type, with kinship, without works - should NEVER be changed.
    # It should revert to "Tag", with associations removed
    fandom = create(:fandom, canonical: true)

    # Tag with incorrect type (Character) and no works - will be cleaned up
    dirty_tag = create(:character,
                       name: "Dirty Tag",
                       canonical: false,
                       taggings_count_cache: 0)

    # Valid association: Character can be a child of Fandom
    CommonTagging.create!(common_tag: dirty_tag, filterable: fandom)

    # 2. Scenario: Legitimate tag - has works, should NOT be changed
    work_tag = create(:character,
                      name: "Work Tag",
                      canonical: false,
                      taggings_count_cache: 5) # has work, not within scope

    CommonTagging.create!(common_tag: work_tag, filterable: fandom)

    # 3. Scenario: Canonical tag - should NEVER be changed
    canonical_tag = create(:fandom,
                           name: "Official Fandom",
                           canonical: true)

    # Executing the Rake Task
    rake_task.reenable # allow running more than once in the same test
    rake_task.invoke

    # Checks
    # Incorrect tag: should revert to generic tag and lose associations
    dirty_tag = Tag.find(dirty_tag.id)
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
