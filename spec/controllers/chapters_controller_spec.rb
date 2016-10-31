require 'spec_helper'

describe ChaptersController do
  include LoginMacros
  
  describe "create" do
    before do
      @user = FactoryGirl.create(:user)
      fake_login_known_user(@user)
      @work = FactoryGirl.create(:work, authors: [@user.pseuds.first])
      @chapter_attributes = { content: "This doesn't matter" }

    end
    
    it "should add a new chapter" do
      expect {
        post :create, { work_id: @work.id, chapter: @chapter_attributes }
      }.to change(Chapter, :count)
      expect(@work.chapters.count).to eq 2
    end
    
    it "should not allow a user to submit only a pseud that is not theirs" do
      @user2 = FactoryGirl.create(:user)
      @chapter_attributes[:author_attributes] = {:ids => [@user2.pseuds.first.id]}
      expect {
        post :create, { work_id: @work.id, chapter: @chapter_attributes }
      }.to_not change(Chapter, :count)
      expect(response).to render_template("new")
      expect(flash[:error]).to eq "You're not allowed to use that pseud."
    end
  end
  
end