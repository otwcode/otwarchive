require 'spec_helper'

describe ChaptersController do
  include LoginMacros
  include RedirectExpectationHelper

  before do
    @user = FactoryGirl.create(:user)
    @work = FactoryGirl.create(:work, posted: true, authors: [@user.pseuds.first])
  end

  describe "index" do
    it "should redirect to work" do
      get :index, work_id: @work.id
      it_redirects_to work_path(@work.id)
    end
  end

  describe "manage" do
    context "when user is logged out" do
      it "should error and redirect to login" do
        get :manage, work_id: @work.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(@user)
      end

      it "should error and redirect to root path if work does not exist" do
        get :manage, work_id: nil
        it_redirects_to_with_error(root_path, "Sorry, we couldn't find the work you were looking for.")
      end

      it "should render manage template" do
        get :manage, work_id: @work.id
        expect(response).to render_template(:manage)
      end

      it "should assign @chapters to only posted chapters" do
        @chapter = FactoryGirl.create(:chapter, work: @work, authors: [@user.pseuds.first], posted: false)
        get :manage, work_id: @work.id
        expect(assigns[:chapters]).to eq([@work.chapters.first])
      end

      it "should assign @chapters to chapters in order" do
        @chapter = FactoryGirl.create(:chapter, work: @work, authors: [@user.pseuds.first], position: 2, posted: true)
        get :manage, work_id: @work.id
        expect(assigns[:chapters]).to eq([@work.chapters.first, @chapter])
      end
    end

    context "when other user is logged in" do
      it "should error and redirect to work" do
        fake_login
        get :manage, work_id: @work.id
        it_redirects_to_with_error(work_path(@work.id), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end 

  describe "create" do
    before do
      fake_login_known_user(@user)
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