require 'spec_helper'

describe "Works" do

  context "interacting with moderated collections" do

    before do
      @collection = Factory.create(:collection)
      @collection_owner = @collection.owners.first
      visit login_path
      fill_in "User name",with: "#{@collection_owner.name}"
      fill_in "Password", with: "#{@collection_owner.password}"
      check "Remember me"
      click_button "Log in"
      visit edit_collection_path(@collection)
      check "This collection is moderated"
      click_button "Update"
      visit logout_path
      visit login_path
      fill_in "User name",with: "testy"
      fill_in "Password", with: "t3st1ng"
      check "Remember me"
      click_button "Log in"
    end

    it "should generate notice when creating a draft" do
      visit new_work_path
      fill_in "work_fandom", with: "Merlin (TV)"
      fill_in "work_title", with: "A Work Added To A Moderated Collection"
      fill_in "work_collection_names", with: "#{@collection.name}"
      fill_in "work[chapter_attributes][content]", with: "This is my lovely content."
      click_button "Preview"
      should have_content("Draft was successfully created. Your work will only show up in the moderated collection you have submitted it to once it is approved by a moderator.")
    end

    it "should generate a notice when first posting to collection"
    it "should not generate a notice when editing an approved work"

  end

  context "interacting with non-moderated collections" do
    # Not really sure if this needs tests. Would just fall under the tests that
    # we want to have for works.
    before do
      # Some stuff goes here
    end
  end

end