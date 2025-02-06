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
end
