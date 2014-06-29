require 'spec_helper'

describe InboxHelper do

  describe "commentable_description_link" do
    context "for Deleted Objects" do
      it "should return the String 'Deleted Object'" do
        @commentable = FactoryGirl.create(:comment)
        @work = @commentable.ultimate_parent
        @work.destroy
        @commentable.reload
        commentable_description_link(@commentable).should eq "Deleted Object"
      end
    end

    context "for Tags" do
      it "should return a link to the Comment on the Tag" do
        @commentable = FactoryGirl.create(:tag_comment)
        string = commentable_description_link(@commentable)
        string.gsub("%20"," ").should eq "<a href=\"/tags/#{@commentable.ultimate_parent.name}/comments/#{@commentable.id}\">#{@commentable.ultimate_parent.name}</a>"
      end
    end

    context "for AdminPosts" do
      it "should return a link to the Comment on the Adminpost" do
        @commentable = FactoryGirl.create(:adminpost_comment)
        commentable_description_link(@commentable).should eq "<a href=\"/admin_posts/#{@commentable.ultimate_parent.id}/comments/#{@commentable.id}\">#{@commentable.ultimate_parent.title}</a>"
      end
    end

    context "for Works" do
      it "should return a link to the Comment on the Work" do
        @commentable = FactoryGirl.create(:comment)
        commentable_description_link(@commentable).should eq "<a href=\"/works/#{@commentable.ultimate_parent.id}/comments/#{@commentable.id}\">#{@commentable.ultimate_parent.title}</a>"
      end
    end
  end
end