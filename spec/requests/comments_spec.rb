require 'spec_helper'

# This code block is used for logged out users and logged in users, on unrestricted works
shared_examples_for "one another" do
  describe "on unrestricted works" do
    before do
      @work2 = Factory.create(:work, :posted => true, :fandom_string => "Merlin (TV)", restricted: "false" )
      @work2.index.refresh
      @comment2 = Comment.create(:comment)
      @work2.comments << @comment2
    end
    it "should be creatable by guests and users on a work" do
      visit "/works/#{@work2.id}/comments/new"
      should have_content("#{@work2.title}")
    end
    it "should be creatable by guests and users on a work's chapter" do
      visit "/works/#{@work2.id}/chapters/#{@work2.chapters.last.id}/comments/new"
      should have_content("#{@work2.title}")
    end
    it "should be readable by guests and users on a work" do
      visit "/works/#{@work2.id}/comments"
      should have_content("#{@work2.title}")
    end
    it "should be readable by guests and users on a work's chapter" do
      visit "/works/#{@work2.id}/chapters/#{@work2.chapters.last.id}/comments"
      should have_content("#{@work2.title}")
    end
    it "should be directly readable by guests and users on a work" do
      visit "/works/#{@work2.id}/comments/#{@comment2.id}"
      should have_content("#{@work2.title}")
    end
    it "should be directly readable by guests and users on a work's chapter" do
      visit "/works/#{@work2.id}/chapters/#{@work2.chapters.last.id}/comments/#{@comment2.id}"
      should have_content("#{@work2.title}")
    end
  end
end

describe "Comments" do
    subject { page }
  describe "on restricted works" do
    before do
      @work1 = Factory.create(:work, :posted => true, :fandom_string => "Merlin (TV)", restricted: "true" )
      @work1.index.refresh
      @comment = Comment.create(:comment)
      @work1.comments << @comment
    end

    it "should not be creatable by guests on a work" do
      visit "/works/#{@work1.id}/comments/new"
      should have_content("Commenting on this work is only available to registered users of the Archive.")
    end
    it "should not be creatable by guests on a work's chapter" do
      visit "/works/#{@work1.id}/chapters/#{@work1.chapters.last.id}/comments/new"
      should have_content("Commenting on this work is only available to registered users of the Archive.")
    end
    it "should not be readable by guests on a work" do
      visit "/works/#{@work1.id}/comments"
      should have_content("Commenting on this work is only available to registered users of the Archive.")
    end
    it "should not be readable by guests on a work's chapter" do
      visit "/works/#{@work1.id}/chapters/#{@work1.chapters.last.id}/comments"
      should have_content("Commenting on this work is only available to registered users of the Archive.")
    end
    it "should not be directly readable by guests on a work" do
      visit "/works/#{@work1.id}/comments/#{@comment.id}"
      should have_content("Commenting on this work is only available to registered users of the Archive.")
    end
    it "should not be directly readable by guests on a work's chapter" do
      visit "/works/#{@work1.id}/chapters/#{@work1.chapters.last.id}/comments/#{@comment.id}"
      should have_content("Commenting on this work is only available to registered users of the Archive.")
    end
  end
  describe "guests and logged in users" do
    it_behaves_like "one another" do
      before do
        visit login_path
        fill_in "User name",with: "testy"
        fill_in "Password", with: "t3st1ng"
        check "Remember me"
        click_button "Log in"
      end
    end
  end
end
