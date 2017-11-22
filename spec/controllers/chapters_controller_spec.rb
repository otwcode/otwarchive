require 'spec_helper'

describe ChaptersController do
  include LoginMacros
  include RedirectExpectationHelper

  let (:user) { create(:user) }

  before do
    @work = create(:work, authors: [user.pseuds.first], posted: true)
  end

  describe "new" do
    context "when non-author user is logged in" do
      before do
        fake_login
      end

      it "errors and redirects to work" do
        get :new, work_id: @work.id
        it_redirects_to_with_error(work_path(@work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "edit" do
    context "when non-author user is logged in" do
      before do
        fake_login
      end

      it "errors and redirects to work" do
        get :edit, work_id: @work.id, id: @work.chapters.first.id
        it_redirects_to_with_error(work_path(@work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end
  
  describe "create" do
    before do
      @chapter_attributes = { content: "This doesn't matter" }
    end

    context "when work author is logged in" do
      before do
        fake_login_known_user(user)
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

    context "when non-author user is logged in" do
      before do
        fake_login
      end

      it "errors and redirects to work" do
        post :create, work_id: @work.id, chapter: @chapter_attributes
        it_redirects_to_with_error(work_path(@work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end
  
  describe "update" do
    before do
      @chapter_attributes = { content: "This doesn't matter" }
    end

    context "when non-author user is logged in" do
      before do
        fake_login
      end

      it "errors and redirects to work" do
        put :update, work_id: @work.id, id: @work.chapters.first.id, chapter: @chapter_attributes
        it_redirects_to_with_error(work_path(@work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end
end
