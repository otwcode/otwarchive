require 'spec_helper'

describe ChaptersController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }

  before do
    @work = create(:work, posted: true, authors: [user.pseuds.first])
  end

  describe "index" do
    it "redirects to work" do
      get :index, work_id: @work.id
      it_redirects_to work_path(@work.id)
    end
  end

  describe "manage" do
    context "when user is logged out" do
      it "errors and redirects to login" do
        get :manage, work_id: @work.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "errors and redirects to root path if work does not exist" do
        get :manage, work_id: nil
        it_redirects_to_with_error(root_path, "Sorry, we couldn't find the work you were looking for.")
      end

      it "renders manage template" do
        get :manage, work_id: @work.id
        expect(response).to render_template(:manage)
      end

      it "assigns @chapters to only posted chapters" do
        @chapter = create(:chapter, work: @work, authors: @work.authors, posted: false)
        get :manage, work_id: @work.id
        expect(assigns[:chapters]).to eq([@work.chapters.first])
      end

      it "assigns @chapters to chapters in order" do
        @chapter = create(:chapter, work: @work, authors: @work.authors, position: 2, posted: true)
        get :manage, work_id: @work.id
        expect(assigns[:chapters]).to eq([@work.chapters.first, @chapter])
      end
    end

    context "when other user is logged in" do
      it "errors and redirects to work" do
        fake_login
        get :manage, work_id: @work.id
        it_redirects_to_with_error(work_path(@work.id), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "show" do
    context "when user is logged out" do
      it "renders show template" do
        get :show, work_id: @work.id, id: @work.chapters.first
        expect(response).to render_template(:show)
      end

      it "errors and redirects to login when work is restricted" do
        @restricted_work = create(:work, posted: true, restricted: true)
        get :show, work_id: @restricted_work.id, id: @restricted_work.chapters.first
        it_redirects_to(login_path(restricted: true))
      end

      it "assigns @chapters to only posted chapters" do
        @chapter = create(:chapter, work: @work, authors: @work.authors, posted: false)
        get :show, work_id: @work.id, id: @chapter.id
        expect(assigns[:chapters]).to eq([@work.chapters.first])
      end

      it "errors and redirects to login when trying to view unposted chapter" do
        @chapter = create(:chapter, work: @work, authors: @work.authors, posted: false)
        get :show, work_id: @work.id, id: @chapter.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work is adult" do
      render_views

      before do
        allow_any_instance_of(Work).to receive(:adult?).and_return true
      end

      it "stores adult preference in sessions when given" do
        get :show, work_id: @work.id, id: @work.chapters.first, view_adult: true
        expect(session[:adult]).to be true
      end

      it "renders _adults template if work is adult and adult permission has not been given" do
        get :show, work_id: @work.id, id: @work.chapters.first
        expect(response).to render_template("works/_adult")
      end

      it "does not render _adults template if work is adult and adult permission has been given" do
        get :show, work_id: @work.id, id: @work.chapters.first, view_adult: true
        expect(response).not_to render_template("works/_adult")
      end
    end

    context "when work is not adult" do
      render_views
      it "does not render _adults template if work is not adult" do
        get :show, work_id: @work.id, id: @work.chapters.first
        expect(response).not_to render_template("works/_adult")
      end
    end

    it "redirects to chapter with selected_id" do
      @chapter = create(:chapter, work: @work, authors: @work.authors, position: 2, posted: true)
      get :show, work_id: @work.id, id: @work.chapters.first, selected_id: @chapter.id
      it_redirects_to work_chapter_path(work_id: @work.id, id: @chapter.id)
    end

    it "errors and redirects to work if chapter is not found" do
      @chapter = create(:chapter)
      get :show, work_id: @work.id, id: @chapter.id
      it_redirects_to_with_error(work_path(@work), "Sorry, we couldn't find the chapter you were looking for.")
    end

    it "assigns @chapters to chapters in order" do
      @chapter = create(:chapter, work: @work, authors: @work.authors, position: 2, posted: true)
      get :show, work_id: @work.id, id: @chapter.id
      expect(assigns[:chapters]).to eq([@work.chapters.first, @chapter])
    end

    it "assigns @previous_chapter when not on first chapter" do
      @chapter = create(:chapter, work: @work, authors: @work.authors, position: 2, posted: true)
      get :show, work_id: @work.id, id: @chapter.id
      expect(assigns[:previous_chapter]).to eq(@work.chapters.first)
    end

    it "does not assign @previous_chapter when on first chapter" do
      @chapter = create(:chapter, work: @work, authors: @work.authors, position: 2, posted: true)
      get :show, work_id: @work.id, id: @work.chapters.first.id
      expect(assigns[:previous_chapter]).to be_nil
    end

    it "assigns @next_chapter when not on last chapter" do
      @chapter = create(:chapter, work: @work, authors: @work.authors, position: 2, posted: true)
      get :show, work_id: @work.id, id: @work.chapters.first.id
      expect(assigns[:next_chapter]).to eq(@chapter)
    end

    it "does not assign @next_chapter when on last chapter" do
      @chapter = create(:chapter, work: @work, authors: @work.authors, position: 2, posted: true)
      get :show, work_id: @work.id, id: @chapter.id
      expect(assigns[:next_chapter]).to be_nil
    end

    it "assigns @comments to only reviewed comments" do
      @moderated_work = create(:work, posted: true, moderated_commenting_enabled: true)
      @comment = create(:comment, commentable_type: "Chapter", commentable_id: @moderated_work.chapters.first.id)
      @comment.unreviewed = false
      @comment.save
      @unreviewed_comment = create(:comment, unreviewed: true, commentable_type: "Chapter", commentable_id: @moderated_work.chapters.first.id)
      get :show, work_id: @moderated_work.id, id: @moderated_work.chapters.first.id
      expect(assigns[:comments]).to eq [@comment]
    end

    it "assigns @page_title with fandom, author name, work title, and chapter" do
      expect_any_instance_of(ChaptersController).to receive(:get_page_title).with("Testing", user.pseuds.first.name, "My title is long enough - Chapter 1").and_return("page title")
      get :show, work_id: @work.id, id: @work.chapters.first.id
      expect(assigns[:page_title]).to eq("page title")
    end

    it "assigns @page_title with unrevealed work" do
      allow_any_instance_of(Work).to receive(:unrevealed?).and_return(true)
      get :show, work_id: @work.id, id: @work.chapters.first.id
      expect(assigns[:page_title]).to eq("Mystery Work - Chapter 1")
    end

    it "assigns @page_title with anonymous work" do
      allow_any_instance_of(Work).to receive(:anonymous?).and_return(true)
      expect_any_instance_of(ChaptersController).to receive(:get_page_title).with("Testing", "Anonymous", "My title is long enough - Chapter 1").and_return("page title")
      get :show, work_id: @work.id, id: @work.chapters.first.id
      expect(assigns[:page_title]).to eq("page title")
    end

    it "assigns @kudos to non-anonymous kudos" do
      @kudo = create(:kudo, commentable_id: @work.id, pseud: create(:pseud))
      @anonymous_kudo = create(:kudo, commentable: @work)
      get :show, work_id: @work.id, id: @work.chapters.first.id
      expect(assigns[:kudos]).to eq [@kudo]
    end

    it "assigns instance variables correctly" do
      @second_chapter = create(:chapter, work: @work, authors: @work.authors, position: 2, posted: true)
      @third_chapter = create(:chapter, work: @work, authors: @work.authors, position: 3, posted: true)
      @comment = create(:comment, commentable_type: "Chapter", commentable_id: @second_chapter.id)
      @kudo = create(:kudo, commentable_id: @work.id, pseud: create(:pseud))
      @tag = create(:fandom)
      expect_any_instance_of(Work).to receive(:tag_groups).and_return({"Fandom" => [@tag]})
      expect_any_instance_of(ChaptersController).to receive(:get_page_title).with("The 1 Fandom", user.pseuds.first.name, "My title is long enough - Chapter 2").and_return("page title")
      get :show, re: @work.id, id: @second_chapter.id
      expect(assigns[:work]).to eq @work
      expect(assigns[:tag_groups]).to eq "Fandom" => [@tag]
      expect(assigns[:chapter]).to eq @second_chapter
      expect(assigns[:chapters]).to eq [@work.chapters.first, @second_chapter, @third_chapter]
      expect(assigns[:previous_chapter]).to eq @work.chapters.first
      expect(assigns[:next_chapter]).to eq @third_chapter
      expect(assigns[:commentable]).to eq @work
      expect(assigns[:comments]).to eq [@comment]
      expect(assigns[:page_title]).to eq "page title"
      expect(assigns[:kudos]).to eq [@kudo]
      expect(assigns[:subscription]).to be_nil
    end

    it "increments the hit count when accessing the first chapter" do
      clean_the_database
      expect {
        get :show, work_id: @work.id, id: @work.chapters.first.id
      }.to change { REDIS_GENERAL.get("work_stats:#{@work.id}:hit_count").to_i }.from(0).to(1)
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user user
      end

      it "assigns @chapters to all chapters" do
        @chapter = create(:chapter, work: @work, authors: @work.authors, position: 2, posted: false)
        get :show, work_id: @work.id, id: @chapter.id
        expect(assigns[:chapters]).to eq([@work.chapters.first, @chapter])
      end
    end     

    context "when other user is logged in" do
      before do
        fake_login
      end

      it "assigns @chapters to only posted chapters" do
        @chapter = create(:chapter, work: @work, authors: @work.authors, posted: false)
        get :show, work_id: @work.id, id: @chapter.id
        expect(assigns[:chapters]).to eq([@work.chapters.first])
      end

      it "assigns @subscription to user's subscription when user is subscribed to work" do
        @subscription = create(:subscription, subscribable: @work, user: @current_user)
        get :show, work_id: @work, id: @work.chapters.first.id
        expect(assigns[:subscription]).to eq(@subscription)
      end

      it "assigns @subscription to unsaved subscription when user is not subscribed to work" do
        get :show, work_id: @work, id: @work.chapters.first.id
        expect(assigns[:subscription]).to be_new_record
      end

      it "updates the reading history" do
        expect(Reading).to receive(:update_or_create).with(@work, @current_user)
        get :show, work_id: @work.id, id: @work.chapters.first.id
      end
    end
  end

  describe "new" do
    context "when user is logged out" do
      it "errors and redirects to login" do
        get :new, work_id: @work.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "renders new template" do
        get :new, work_id: @work.id
        expect(response).to render_template(:new)
      end

      it "assigns instance variables correctly" do
        get :new, work_id: @work.id
        expect(assigns[:work]).to eq @work
        expect(assigns[:allpseuds]).to eq user.pseuds
        expect(assigns[:pseuds]).to eq user.pseuds
        expect(assigns[:coauthors]).to eq []
        expect(assigns[:selected_pseuds]).to eq [ user.pseuds.first.id.to_i ]
      end

      it "errors and redirects to user page when user is banned" do
        current_user = create(:user, banned: true)
        @banned_users_work = create(:work, posted: true, authors: [current_user.pseuds.first])
        fake_login_known_user(current_user)
        get :new, work_id: @banned_users_work.id
        it_redirects_to(user_path(current_user))
        expect(flash[:error]).to include("Your account has been banned.")
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      it "renders new template" do
        get :new, work_id: @work.id
        expect(response).to render_template(:new)
      end

      it "gives a error when the user is not an owner of the work" do
        get :new, work_id: @work.id
        expect(flash[:error]).to eq("You're not allowed to use that pseud.")
      end
    end
  end

  describe "edit" do
    context "when user is logged out" do
      it "errors and redirects to login" do
        get :edit, work_id: @work.id, id: @work.chapters.first.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "renders new template" do
        get :edit, work_id: @work.id, id: @work.chapters.first.id
        expect(response).to render_template(:edit)
      end

      it "assigns instance variables correctly" do
        get :edit, work_id: @work.id, id: @work.chapters.first.id
        expect(assigns[:work]).to eq @work
        expect(assigns[:allpseuds]).to eq user.pseuds
        expect(assigns[:pseuds]).to eq user.pseuds
        expect(assigns[:coauthors]).to eq []
        expect(assigns[:selected_pseuds]).to eq [ user.pseuds.first.id.to_i ]
      end

      it "errors and redirects to user page when user is banned" do
        current_user = create(:user, banned: true)
        @banned_users_work = create(:work, posted: true, authors: [current_user.pseuds.first])
        fake_login_known_user(current_user)
        get :edit, work_id: @banned_users_work.id, id: @banned_users_work.chapters.first.id
        it_redirects_to(user_path(current_user))
        expect(flash[:error]).to include("Your account has been banned.")
      end

      it "removes user and redirects to work when user removes themselves" do
        @other_user = create(:user)
        @chapter = create(:chapter, work: @work, posted: true, authors: [user.pseuds.first, @other_user.pseuds.first])
        get :edit, work_id: @work.id, id: @chapter.id, remove: "me"
        expect(assigns[:chapter].pseuds).to eq [@other_user.pseuds.first]
        it_redirects_to(work_path(@work))
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      it "gives an error when the user is not an owner of the work" do
        get :edit, work_id: @work.id, id: @work.chapters.first.id
        expect(flash[:error]).to eq("You're not allowed to use that pseud.")
      end
    end
  end

  describe "create" do
    before do
      fake_login_known_user(user)
      @chapter_attributes = { content: "This doesn't matter" }
    end
    
    it "adds a new chapter" do
      expect {
        post :create, { work_id: @work.id, chapter: @chapter_attributes }
      }.to change(Chapter, :count)
      expect(@work.chapters.count).to eq 2
    end
    
    it "does not allow a user to submit only a pseud that is not theirs" do
      user2 = create(:user)
      @chapter_attributes[:author_attributes] = {:ids => [user2.pseuds.first.id]}
      expect {
        post :create, { work_id: @work.id, chapter: @chapter_attributes }
      }.to_not change(Chapter, :count)
      expect(response).to render_template("new")
      expect(flash[:error]).to eq "You're not allowed to use that pseud."
    end
  end
end