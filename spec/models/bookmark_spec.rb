# frozen_string_literal: true

require "spec_helper"

describe Bookmark do
  it "has a valid factory" do
    expect(build(:bookmark)).to be_valid
  end

  it "has a valid factory for external work bookmarks" do
    expect(build(:external_work_bookmark)).to be_valid
  end

  it "has a valid factory for series bookmarks" do
    expect(build(:series_bookmark)).to be_valid
  end

  it "is invalid without a pseud_id" do
    bookmark = build(:bookmark, pseud_id: nil)
    expect(bookmark).to_not be_valid
    expect(bookmark.errors[:pseud].first).to eq("can't be blank")
  end

  it "can be tagged if has an id larger than int" do
    bookmark = build(:bookmark, tag_string: "Huge", id: 2247740375)
    expect(bookmark).to be_valid
    expect(bookmark.save).to be_truthy
    expect(bookmark.reload.taggings.last.tagger.name).to eq("Huge")
  end

  it "can be collected if has an id larger than int" do
    collection = create(:collection)
    bookmark = build(:bookmark, collection_names: collection.name, id: 2247740375)
    expect(bookmark).to be_valid
    expect(bookmark.save).to be_truthy
    expect(bookmark.collections).to include(collection)
    expect(collection.bookmarks).to include(bookmark)
  end

  it "can be hidden if has an id larger than int" do
    bookmark = create(:bookmark, id: 2247740375)
    admin = create(:admin)
    activity = build(:admin_activity, admin: admin, target: bookmark)

    expect(activity).to be_valid
    expect(activity.save).to be_truthy
    expect(activity.target_name).to eq("Bookmark #{bookmark.id}")
  end
end
