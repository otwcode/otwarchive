require 'spec_helper'

describe "Comments" do
    subject { page }
  describe "on restricted works" do
    before do
      @fandom2 = Factory.create(:fandom)
      @work2 = Factory.create(:work, :posted => true, :fandom_string => "Merlin (TV)", restricted: "true" )
      @work2.index.refresh
      @comment = Comment.create(:comment)
      @work2.comments << @comment
    end

    it "should not be creatable by guests" do
      visit "/works/#{@work2.id}/comments/new"
      should have_content("Commenting on this work is only available to registered users of the Archive.")

      visit "/works/#{@work2.id}/chapters/#{@work2.chapters.last.id}/comments/new"
      should have_content("Commenting on this work is only available to registered users of the Archive.")
    end

    it "should not be readable by guests" do
      visit "/works/#{@work2.id}/comments"
      should have_content("Commenting on this work is only available to registered users of the Archive.")

      visit "/works/#{@work2.id}/chapters/#{@work2.chapters.last.id}/comments"
      should have_content("Commenting on this work is only available to registered users of the Archive.")

      visit "/works/#{@work2.id}/chapters/#{@work2.chapters.last.id}/comments/#{@comment.id}"
      should have_content("Commenting on this work is only available to registered users of the Archive.")

      visit "/works/#{@work2.id}/comments/#{@comment.id}"
      should have_content("Commenting on this work is only available to registered users of the Archive.")
    end

  end
end
