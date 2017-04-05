require 'spec_helper'

describe ChaptersController do
  include LoginMacros
  
  describe "create" do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:work) { create(:work, authors: [user.pseuds.first]) }

    before do
      fake_login_known_user(user)
      @chapter_attributes = { content: "This doesn't matter" }
    end
    
    it "adds a new chapter" do
      expect {
        post :create, { work_id: work.id, chapter: @chapter_attributes }
      }.to change(Chapter, :count)
      expect(work.chapters.count).to eq 2
    end
    
    it "errors and renders new if a user submits only a pseud that is not theirs" do
      @chapter_attributes[:author_attributes] = {:ids => [user2.pseuds.first.id]}
      expect {
        post :create, { work_id: work.id, chapter: @chapter_attributes }
      }.to_not change(Chapter, :count)
      expect(response).to render_template("new")
      expect(flash[:error]).to eq "You're not allowed to use that pseud."
    end
  end
  
end