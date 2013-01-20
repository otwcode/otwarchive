require 'spec_helper'

describe "Works" do
  subject { page }

  context "interacting with moderated collections" do
    before do
      # Set up our collection and our users (collection has an automatic owner)
      @collection = Factory.create(:collection)
      @collection.owners.first.user.activate
      @testy = Factory.create(:user)
      @testy.activate

      visit login_path
      fill_in "User name",with: "#{@collection.owners.first.user.login}"
      fill_in "Password", with: "password"
      click_button "Log in"

      visit edit_collection_path(@collection)
      should have_content("Edit Collection")
      check("This collection is moderated")
      click_button "Update"
      visit logout_path

      visit login_path
      fill_in "User name",with: "#{@testy.login}"
      fill_in "Password", with: "password"
      click_button "Log in"
    end

    it "should generate notice when creating a draft" do
      visit new_work_path
      fill_in "Fandoms*", with: "Merlin (TV)"
      fill_in "Work Title *", with: "A Work Added To A Moderated Collection"
      fill_in "Post to Collections / Challenges", with: "#{@collection.name}"
      fill_in "content", with: "This is my lovely content."
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