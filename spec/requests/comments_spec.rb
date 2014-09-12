require 'spec_helper'

def comment_attributes_guest
  { content: "Body text of the comment", email: "donotreply@ao3.org", name: "guest" }
end

def comment_attributes_user
  { content: "Body text of the comment", pseud_id: FactoryGirl.create(:pseud).id }
end

# This code block is used for logged out users and logged in users, on unrestricted works
shared_examples_for "on unrestricted works", :pending do
    before do
      @work2 = create(:work, posted: true, fandom_string: "Merlin (TV)", title: "My title is long enough", restricted: "false" )
      @work2.index.refresh
      @comment2 = create(:comment)
      @work2.comments << @comment2
    end

    #has been added
    it "should be creatable on a work" do
      visit "/works/#{@work2.id}/comments/new"
      should have_content("#{@work2.title}")
    end

    it "should be creatable on a work's chapter" do
      visit "/works/#{@work2.id}/chapters/#{@work2.chapters.last.id}/comments/new"
      should have_content("#{@work2.title}")
    end

    it "should be readable on a work" do
      visit "/works/#{@work2.id}/comments"
      should have_content("#{@work2.title}")
    end

    it "should be readable on a work's chapter" do
      visit "/works/#{@work2.id}/chapters/#{@work2.chapters.last.id}/comments"
      should have_content("#{@work2.title}")
    end

    it "should be directly readable on a work" do
      visit "/works/#{@work2.id}/comments/#{@comment2.id}"
      should have_content("#{@work2.title}")
    end

    it "should be directly readable on a chapter" do
      visit "/chapters/#{@work2.chapters.last.id}/comments/#{@comment2.id}"
      should have_content("#{@work2.title}")
    end

    it "should be directly readable on a work's chapter" do
      visit "/works/#{@work2.id}/chapters/#{@work2.chapters.last.id}/comments/#{@comment2.id}"
      should have_content("#{@work2.title}")
    end
end

describe "Comments" do
    subject { page }
  context "on restricted works" do
    before do
      @work1 = create(:work, posted: true, fandom_string: "Merlin (TV)", title: "My title is long enough", restricted: "true" )
      @work1.index.refresh
      @comment = create(:comment)
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
    xit "should not be directly readable by guests on a work" do
      visit "/works/#{@work1.id}/comments/#{@comment.id}"
      should have_content("Commenting on this work is only available to registered users of the Archive.")
    end
    xit "should not be directly readable by guests on a work's chapter" do
      visit "/works/#{@work1.id}/chapters/#{@work1.chapters.last.id}/comments/#{@comment.id}"
      should have_content("Commenting on this work is only available to registered users of the Archive.")
    end
  end

  context "guests" do
    it_behaves_like "on unrestricted works" do
    end
  end

  context "logged in users" do
    before do
      @user = create(:user)
      visit login_path
      within("div#small_login") do
        fill_in "User name:",with: "#{@user.login}" ,  exact: true
        fill_in "Password", with: "password" 
        check "Remember Me"
        click_button "Log In"
      end
    end

    it_behaves_like "on unrestricted works" do
    end
  end

  context "on works which have anonymous commenting disabled" do
    before do
      @work = create(:work, posted: true, fandom_string: "Merlin (TV)", anon_commenting_disabled: "true" )
      @work.index.refresh
      @comment = create(:comment)
      @work.comments << @comment
    end

    it "should not be creatable by guests on a work" do
      visit "/works/#{@work.id}/comments/new"
      should have_content("Sorry, this work doesn't allow non-Archive users to comment.")
      should_not have_button "Reply"
      should_not have_button "Comment"
    end

    it "should not be creatable by guests on a work's chapter" do
      visit "/works/#{@work.id}/chapters/#{@work.chapters.last.id}/comments/new"
      should have_content("Sorry, this work doesn't allow non-Archive users to comment.")
      should_not have_button "Reply"
      should_not have_button "Comment"
    end

    it "should not be able to be replied to by guests on a work" do
      visit "/works/#{@work.id}/comments/#{@comment.id}"
      should_not have_button "Reply"
    end

    it "should not be able to be replied to by guests on a work's chapter" do
      visit "/works/#{@work.id}/chapters/#{@work.chapters.last.id}/comments/#{@comment.id}"
      should_not have_button "Reply"
    end
  end
end
