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
    expect(build(:bookmark, pseud_id: nil)).to_not be_valid
  end
end
