require 'spec_helper'

describe ChaptersController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }
  let!(:work) { create(:posted_work, authors: [user.pseuds.first]) }
  let(:unposted_work) { create(:work, authors: [user.pseuds.first]) }
  let(:banned_user) { create(:user, banned: true) }
  let(:banned_users_work) { create(:work, posted: true, authors: [banned_user.pseuds.first]) }


  describe "index" do
    it "redirects to work" do
      get :index, params: { work_id: work.id }
      it_redirects_to work_path(work.id)
    end
  end

  describe "manage" do
    context "when user is logged out" do
      it "errors and redirects to login" do
        get :manage, params: { work_id: work.id }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "errors and redirects to root path if work does not exist" do
        get :manage, params: { work_id: 0 }
        it_redirects_to_with_error(root_path, "Sorry, we couldn't find the work you were looking for.")
      end

      it "renders manage template" do
        get :manage, params: { work_id: work.id }
        expect(response).to render_template(:manage)
      end

      it "assigns @chapters to only posted chapters" do
        create(:chapter, work: work, authors: work.authors, posted: false)
        get :manage, params: { work_id: work.id }
        expect(assigns[:chapters]).to eq([work.chapters.first])
      end

      it "assigns @chapters to chapters in order" do
        chapter = create(:chapter, work: work, authors: work.authors, position: 2, posted: true)
        get :manage, params: { work_id: work.id }
        expect(assigns[:chapters]).to eq([work.chapters.first, chapter])
      end
    end

    context "when other user is logged in" do
      it "errors and redirects to work" do
        fake_login
        get :manage, params: { work_id: work.id }
        it_redirects_to_with_error(work_path(work.id), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "show" do
    context "when user is logged out" do
      it "renders show template" do
        get :show, params: { work_id: work.id, id: work.chapters.first }
        expect(response).to render_template(:show)
      end

      it "errors and redirects to login when work is restricted" do
        restricted_work = create(:work, posted: true, restricted: true)
        get :show, params: { work_id: restricted_work.id, id: restricted_work.chapters.first }
        it_redirects_to(login_path(restricted: true))
      end

      it "assigns @chapters to only posted chapters" do
        chapter = create(:chapter, work: work, authors: work.authors, posted: false)
        get :show, params: { work_id: work.id, id: chapter.id }
        expect(assigns[:chapters]).to eq([work.chapters.first])
      end

      it "errors and redirects to login when trying to view unposted chapter" do
        chapter = create(:chapter, work: work, authors: work.authors, posted: false)
        get :show, params: { work_id: work.id, id: chapter.id }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work is adult" do
      render_views

      before do
        allow_any_instance_of(Work).to receive(:adult?).and_return true
      end

      it "stores adult preference in sessions when given" do
        get :show, params: { work_id: work.id, id: work.chapters.first, view_adult: true }
        expect(session[:adult]).to be true
      end

      it "renders _adults template if work is adult and adult permission has not been given" do
        get :show, params: { work_id: work.id, id: work.chapters.first }
        expect(response).to render_template("works/_adult")
      end

      it "does not render _adults template if work is adult and adult permission has been given" do
        get :show, params: { work_id: work.id, id: work.chapters.first, view_adult: true }
        expect(response).not_to render_template("works/_adult")
      end
    end

    context "when work is not adult" do
      render_views
      it "does not render _adults template if work is not adult" do
        get :show, params: { work_id: work.id, id: work.chapters.first }
        expect(response).not_to render_template("works/_adult")
      end
    end

    it "redirects to chapter with selected_id" do
      chapter = create(:chapter, work: work, authors: work.authors, position: 2, posted: true)
      get :show, params: { work_id: work.id, id: work.chapters.first, selected_id: chapter.id }
      it_redirects_to work_chapter_path(work_id: work.id, id: chapter.id)
    end

    it "errors and redirects to work if chapter is not found" do
      chapter = create(:chapter)
      get :show, params: { work_id: work.id, id: chapter.id }
      it_redirects_to_with_error(work_path(work), "Sorry, we couldn't find the chapter you were looking for.")
    end

    it "assigns @chapters to chapters in order" do
      chapter = create(:chapter, work: work, authors: work.authors, position: 2, posted: true)
      get :show, params: { work_id: work.id, id: chapter.id }
      expect(assigns[:chapters]).to eq([work.chapters.first, chapter])
    end

    it "assigns @previous_chapter when not on first chapter" do
      chapter = create(:chapter, work: work, authors: work.authors, position: 2, posted: true)
      get :show, params: { work_id: work.id, id: chapter.id }
      expect(assigns[:previous_chapter]).to eq(work.chapters.first)
    end

    it "does not assign @previous_chapter when on first chapter" do
      create(:chapter, work: work, authors: work.authors, position: 2, posted: true)
      get :show, params: { work_id: work.id, id: work.chapters.first.id }
      expect(assigns[:previous_chapter]).to be_nil
    end

    it "assigns @next_chapter when not on last chapter" do
      chapter = create(:chapter, work: work, authors: work.authors, position: 2, posted: true)
      get :show, params: { work_id: work.id, id: work.chapters.first.id }
      expect(assigns[:next_chapter]).to eq(chapter)
    end

    it "does not assign @next_chapter when on last chapter" do
      chapter = create(:chapter, work: work, authors: work.authors, position: 2, posted: true)
      get :show, params: { work_id: work.id, id: chapter.id }
      expect(assigns[:next_chapter]).to be_nil
    end

    it "assigns @comments to only reviewed comments" do
      moderated_work = create(:posted_work, moderated_commenting_enabled: true)
      comment = create(:comment, commentable_type: "Chapter", commentable_id: moderated_work.chapters.first.id)
      comment.unreviewed = false
      comment.save
      create(:comment, unreviewed: true, commentable_type: "Chapter", commentable_id: moderated_work.chapters.first.id)
      get :show, params: { work_id: moderated_work.id, id: moderated_work.chapters.first.id }
      expect(assigns[:comments]).to eq [comment]
    end

    it "assigns @page_title with fandom, author name, work title, and chapter" do
      expect_any_instance_of(ChaptersController).to receive(:get_page_title).with("Testing", user.pseuds.first.name, "My title is long enough - Chapter 1").and_return("page title")
      get :show, params: { work_id: work.id, id: work.chapters.first.id }
      expect(assigns[:page_title]).to eq("page title")
    end

    it "assigns @page_title with unrevealed work" do
      allow_any_instance_of(Work).to receive(:unrevealed?).and_return(true)
      get :show, params: { work_id: work.id, id: work.chapters.first.id }
      expect(assigns[:page_title]).to eq("Mystery Work - Chapter 1")
    end

    it "assigns @page_title with anonymous work" do
      allow_any_instance_of(Work).to receive(:anonymous?).and_return(true)
      expect_any_instance_of(ChaptersController).to receive(:get_page_title).with("Testing", "Anonymous", "My title is long enough - Chapter 1").and_return("page title")
      get :show, params: { work_id: work.id, id: work.chapters.first.id }
      expect(assigns[:page_title]).to eq("page title")
    end

    it "assigns @kudos to non-anonymous kudos" do
      kudo = create(:kudo, commentable_id: work.id, pseud: create(:pseud))
      create(:kudo, commentable: work)
      get :show, params: { work_id: work.id, id: work.chapters.first.id }
      expect(assigns[:kudos]).to eq [kudo]
    end

    it "assigns instance variables correctly" do
      second_chapter = create(:chapter, work: work, authors: work.authors, position: 2, posted: true)
      third_chapter = create(:chapter, work: work, authors: work.authors, position: 3, posted: true)
      comment = create(:comment, commentable_type: "Chapter", commentable_id: second_chapter.id)
      kudo = create(:kudo, commentable_id: work.id, pseud: create(:pseud))
      tag = create(:fandom)
      expect_any_instance_of(Work).to receive(:tag_groups).and_return("Fandom" => [tag])
      expect_any_instance_of(ChaptersController).to receive(:get_page_title).with(tag.name, user.pseuds.first.name, "My title is long enough - Chapter 2").and_return("page title")
      get :show, params: { work_id: work.id, id: second_chapter.id }
      expect(assigns[:work]).to eq work
      expect(assigns[:tag_groups]).to eq "Fandom" => [tag]
      expect(assigns[:chapter]).to eq second_chapter
      expect(assigns[:chapters]).to eq [work.chapters.first, second_chapter, third_chapter]
      expect(assigns[:previous_chapter]).to eq work.chapters.first
      expect(assigns[:next_chapter]).to eq third_chapter
      expect(assigns[:commentable]).to eq work
      expect(assigns[:comments]).to eq [comment]
      expect(assigns[:page_title]).to eq "page title"
      expect(assigns[:kudos]).to eq [kudo]
      expect(assigns[:subscription]).to be_nil
    end

    it "increments the hit count when accessing the first chapter" do
      REDIS_GENERAL.set("work_stats:#{work.id}:last_visitor", nil)
      expect { get :show, params: { work_id: work.id, id: work.chapters.first.id } }.to change { REDIS_GENERAL.get("work_stats:#{work.id}:hit_count").to_i }.by(1)
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "assigns @chapters to all chapters" do
        chapter = create(:chapter, work: work, authors: work.authors, position: 2, posted: false)
        get :show, params: { work_id: work.id, id: chapter.id }
        expect(assigns[:chapters]).to eq([work.chapters.first, chapter])
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      it "assigns @chapters to only posted chapters" do
        chapter = create(:chapter, work: work, authors: work.authors, posted: false)
        get :show, params: { work_id: work.id, id: chapter.id }
        expect(assigns[:chapters]).to eq([work.chapters.first])
      end

      it "assigns @subscription to user's subscription when user is subscribed to work" do
        subscription = create(:subscription, subscribable: work, user: @current_user)
        get :show, params: { work_id: work, id: work.chapters.first.id }
        expect(assigns[:subscription]).to eq(subscription)
      end

      it "assigns @subscription to unsaved subscription when user is not subscribed to work" do
        get :show, params: { work_id: work, id: work.chapters.first.id }
        expect(assigns[:subscription]).to be_new_record
      end

      it "updates the reading history" do
        expect(Reading).to receive(:update_or_create).with(work, @current_user)
        get :show, params: { work_id: work.id, id: work.chapters.first.id }
      end
    end
  end

  describe "new" do
    context "when user is logged out" do
      it "errors and redirects to login" do
        get :new, params: { work_id: work.id }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "renders new template" do
        get :new, params: { work_id: work.id }
        expect(response).to render_template(:new)
      end

      it "assigns instance variables correctly" do
        get :new, params: { work_id: work.id }
        expect(assigns[:work]).to eq work
        expect(assigns[:allpseuds]).to eq user.pseuds
        expect(assigns[:pseuds]).to eq user.pseuds
        expect(assigns[:coauthors]).to eq []
        expect(assigns[:selected_pseuds]).to eq [user.pseuds.first.id]
      end

      it "errors and redirects to user page when user is banned" do
        fake_login_known_user(banned_user)
        get :new, params: { work_id: banned_users_work.id }
        it_redirects_to(user_path(banned_user))
        expect(flash[:error]).to include("Your account has been banned.")
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      it "errors and redirects to work" do
        get :new, params: { work_id: work.id }
        it_redirects_to_with_error(work_path(work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "edit" do
    context "when user is logged out" do
      it "errors and redirects to login" do
        get :edit, params: { work_id: work.id, id: work.chapters.first.id }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "renders edit template" do
        get :edit, params: { work_id: work.id, id: work.chapters.first.id }
        expect(response).to render_template(:edit)
      end

      it "assigns instance variables correctly" do
        get :edit, params: { work_id: work.id, id: work.chapters.first.id }
        expect(assigns[:work]).to eq work
        expect(assigns[:allpseuds]).to eq user.pseuds
        expect(assigns[:pseuds]).to eq user.pseuds
        expect(assigns[:coauthors]).to eq []
        expect(assigns[:selected_pseuds]).to eq [user.pseuds.first.id]
      end

      it "errors and redirects to user page when user is banned" do
        fake_login_known_user(banned_user)
        get :edit, params: { work_id: banned_users_work.id, id: banned_users_work.chapters.first.id }
        it_redirects_to(user_path(banned_user))
        expect(flash[:error]).to include("Your account has been banned.")
      end

      it "removes user, gives notice, and redirects to work when user removes themselves" do
        other_user = create(:user)
        chapter = create(:chapter, work: work, posted: true, authors: [user.pseuds.first, other_user.pseuds.first])
        get :edit, params: { work_id: work.id, id: chapter.id, remove: "me" }
        expect(assigns[:chapter].pseuds).to eq [other_user.pseuds.first]
        it_redirects_to_with_notice(work_path(work), "You have been removed as an author from the chapter")
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      it "errors and redirects to work" do
        get :edit, params: { work_id: work.id, id: work.chapters.first.id }
        it_redirects_to_with_error(work_path(work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "create" do
    before do
      @chapter_attributes = { content: "This doesn't matter" }
    end

    context "when user is logged out" do
      it "errors and redirects to login" do
        post :create, params: { work_id: work.id, chapter: @chapter_attributes }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "errors and redirects to user page when user is banned" do
        fake_login_known_user(banned_user)
        post :create, params: { work_id: banned_users_work.id, chapter: @chapter_attributes }
        it_redirects_to(user_path(banned_user))
        expect(flash[:error]).to include("Your account has been banned.")
      end

      it "does not allow a user to submit only a pseud that is not theirs" do
        user2 = create(:user)
        @chapter_attributes[:author_attributes] = { ids: [user2.pseuds.first.id] }
        expect { post :create, params: { work_id: work.id, chapter: @chapter_attributes } }.to_not change(Chapter, :count)
        expect(response).to render_template("new")
        expect(flash[:error]).to eq "You're not allowed to use that pseud."
      end

      it "assigns instance variables correctly" do
        post :create, params: { work_id: work.id, chapter: @chapter_attributes }
        expect(assigns[:work]).to eq work
        expect(assigns[:allpseuds]).to eq user.pseuds
        expect(assigns[:pseuds]).to eq user.pseuds
        expect(assigns[:coauthors]).to eq []
        expect(assigns[:selected_pseuds]).to eq [user.pseuds.first.id]
      end

      it "adds a new chapter" do
        expect { post :create, params: { work_id: work.id, chapter: @chapter_attributes } }.to change(Chapter, :count)
        expect(work.chapters.count).to eq 2
      end

      it "updates the works wip length when given" do
        @chapter_attributes[:wip_length] = 3
        expect(work.wip_length).to eq 1
        post :create, params: { work_id: work.id, chapter: @chapter_attributes }
        expect(assigns[:work].wip_length).to eq 3
      end

      context "when chapter has invalid pseuds" do
        before do
          allow_any_instance_of(Chapter).to receive(:invalid_pseuds).and_return([user.pseuds.first])
        end
        it "renders choose coauthor if chapter is valid" do
          post :create, params: { work_id: work.id, chapter: @chapter_attributes }
          expect(response).to render_template("_choose_coauthor")
        end

        it "renders new if chapter is not valid" do
          post :create, params: { work_id: work.id, chapter: { content: "" } }
          expect(response).to render_template(:new)
        end
      end

      context "when chapter has ambiguous pseuds" do
        before do
          allow_any_instance_of(Chapter).to receive(:ambiguous_pseuds).and_return([user.pseuds.first])
        end
        it "renders choose coauthor if chapter is valid" do
          post :create, params: { work_id: work.id, chapter: @chapter_attributes }
          expect(response).to render_template("_choose_coauthor")
        end

        it "renders new if chapter is not valid" do
          post :create, params: { work_id: work.id, chapter: { content: "" } }
          expect(response).to render_template(:new)
        end
      end

      it "renders new if the edit button has been clicked" do
        post :create, params: { work_id: work.id, chapter: @chapter_attributes, edit_button: true }
        expect(response).to render_template(:new)
      end

      it "redirects if the cancel button has been clicked" do
        post :create, params: { work_id: work.id, chapter: @chapter_attributes, cancel_button: true }
        expect(response).to have_http_status :redirect
      end

      it "updates the work's major version" do
        expect(work.major_version).to eq(1)
        post :create, params: { work_id: work.id, chapter: @chapter_attributes }
        expect(assigns[:work].major_version).to eq(2)
      end

      context "when the post without preview button is clicked" do
        context "when the chapter and work are valid" do
          it "posts the chapter" do
            post :create, params: { work_id: work.id, chapter: @chapter_attributes, post_without_preview_button: true }
            expect(assigns[:chapter].posted).to be true
          end

          it "posts the work if the work was not posted before" do
            post :create, params: { work_id: unposted_work.id, chapter: @chapter_attributes, post_without_preview_button: true }
            expect(assigns[:work].posted).to be true
          end

          it "gives a notice and redirects to the posted chapter" do
            post :create, params: { work_id: work.id, chapter: @chapter_attributes, post_without_preview_button: true }
            it_redirects_to_with_notice(work_chapter_path(work_id: work.id, id: assigns[:chapter].id), "Chapter has been posted!")
          end
        end

        context "when the chapter or work is not valid" do
          it "does not add a chapter" do
            expect { post :create, params: { work_id: work.id, chapter: { content: "" }, post_without_preview_button: true } }.to_not change(Chapter, :count)
          end

          it "renders new" do
            post :create, params: { work_id: work.id, chapter: { content: "" }, post_without_preview_button: true }
            expect(response).to render_template(:new)
          end
        end

        it "updates the work's revision date" do
          Delorean.time_travel_to("1 day ago") do
            work.touch
          end

          old_updated_at = work.updated_at

          post :create, params: { work_id: work.id, chapter: @chapter_attributes, post_without_preview_button: true }
          expect(assigns[:work].updated_at).not_to eq(old_updated_at)
        end
      end

      context "when the preview button is clicked" do
        context "when the chapter and work are valid" do
          it "does not post the chapter" do
            post :create, params: { work_id: work.id, chapter: @chapter_attributes, preview_button: true }
            expect(assigns[:chapter].posted).to be false
          end

          it "gives a notice that the chapter is a draft and redirects to the chapter preview" do
            post :create, params: { work_id: work.id, chapter: @chapter_attributes, preview_button: true }
            it_redirects_to_with_notice(preview_work_chapter_path(work_id: work.id, id: assigns[:chapter].id), "This is a draft chapter in a posted work. It will be kept unless the work is deleted.")
          end

          it "gives a notice that the work and chapter are drafts and redirects to the chapter preview" do
            post :create, params: { work_id: unposted_work.id, chapter: @chapter_attributes, preview_button: true }
            it_redirects_to(preview_work_chapter_path(work_id: unposted_work.id, id: assigns[:chapter].id))
            expect(flash[:notice]).to include("This is a draft chapter in an unposted work")
          end
        end

        context "when the chapter or work is not valid" do
          it "does not add a chapter" do
            expect { post :create, params: { work_id: work.id, chapter: { content: "" }, preview_button: true } }.to_not change(Chapter, :count)
          end

          it "renders new" do
            post :create, params: { work_id: work.id, chapter: { content: "" }, preview_button: true }
            expect(response).to render_template(:new)
          end
        end
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      context "when the user tries to add themselves as a coauthor" do
        before do
          @chapter_attributes[:author_attributes] = { ids: [user.pseuds.first.id, @current_user.pseuds.first.id] }
        end

        it "errors and redirects to work" do
          post :create, params: { work_id: work.id, chapter: @chapter_attributes }
          it_redirects_to_with_error(work_path(work), "Sorry, you don't have permission to access the page you were trying to reach.")
        end
      end
    end
  end

  describe "update" do
    before do
      @chapter_attributes = { content: "This doesn't matter" }
    end

    context "when user is logged out" do
      it "errors and redirects to login" do
        put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "errors and redirects to user page when user is banned" do
        fake_login_known_user(banned_user)
        put :update, params: { work_id: banned_users_work.id, id: banned_users_work.chapters.first.id, chapter: @chapter_attributes }
        it_redirects_to(user_path(banned_user))
        expect(flash[:error]).to include("Your account has been banned.")
      end

      it "does not allow a user to submit only a pseud that is not theirs" do
        user2 = create(:user)
        @chapter_attributes[:author_attributes] = { ids: [user2.pseuds.first.id] }
        put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes }
        expect(response).to render_template("new")
        expect(flash[:error]).to eq "You're not allowed to use that pseud."
      end

      it "assigns instance variables correctly" do
        put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes }
        expect(assigns[:work]).to eq work
        expect(assigns[:allpseuds]).to eq user.pseuds
        expect(assigns[:pseuds]).to eq user.pseuds
        expect(assigns[:coauthors]).to eq []
        expect(assigns[:selected_pseuds]).to eq [user.pseuds.first.id]
      end

      it "updates the work's wip length when given" do
        @chapter_attributes[:wip_length] = 3
        expect(work.wip_length).to eq 1
        put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes }
        expect(assigns[:work].wip_length).to eq 3
      end

      context "when chapter has invalid pseuds" do
        before do
          allow_any_instance_of(Chapter).to receive(:invalid_pseuds).and_return([user.pseuds.first])
        end
        it "renders choose coauthor if chapter is valid" do
          put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes }
          expect(response).to render_template("_choose_coauthor")
        end

        it "renders new if chapter is not valid" do
          put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: { content: "" } }
          expect(response).to render_template(:new)
        end
      end

      context "when chapter has ambiguous pseuds" do
        before do
          allow_any_instance_of(Chapter).to receive(:ambiguous_pseuds).and_return([user.pseuds.first])
        end
        it "renders choose coauthor if chapter is valid" do
          put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes }
          expect(response).to render_template("_choose_coauthor")
        end

        it "renders new if chapter is not valid" do
          put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: { content: "" } }
          expect(response).to render_template(:new)
        end
      end

      context "when the preview button is clicked" do
        it "assigns preview_mode to true" do
          put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes, preview_button: true }
          expect(assigns[:preview_mode]).to be true
        end

        it "gives a notice if the chapter has been posted and renders preview" do
          put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes, preview_button: true }
          expect(response).to render_template(:preview)
          expect(flash[:notice]).to include "This is a preview of what this chapter will look like after your changes have been applied."
        end

        it "gives a notice if the chapter has not been posted and renders preview" do
          unposted_chapter = create(:chapter, work: work, authors: [user.pseuds.first])
          put :update, params: { work_id: work.id, id: unposted_chapter.id, chapter: @chapter_attributes, preview_button: true }
          expect(response).to render_template(:preview)
          expect(flash[:notice]).to include "This is a draft chapter in a posted work."
        end
      end

      it "redirects if the cancel button has been clicked" do
        put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes, cancel_button: true }
        expect(response).to have_http_status :redirect
      end

      it "renders edit if the edit button has been clicked" do
        put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes, edit_button: true }
        expect(response).to render_template(:edit)
      end

      it "updates the work's minor version" do
        expect(work.minor_version).to eq(0)
        put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes }
        expect(assigns[:work].minor_version).to eq(1)
      end

      context "when the post button is clicked" do
        context "when the chapter and work are valid" do
          it "posts the chapter" do
            put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes, post_button: true }
            expect(assigns[:chapter].posted).to be true
          end

          it "posts the work if the work was not posted before" do
            pending "multi-chapter works should post when chapter is posted"
            put :update, params: { work_id: unposted_work.id, id: unposted_work.chapters.first.id, chapter: @chapter_attributes, post_button: true }
            expect(assigns[:work].posted).to be true
          end

          it "gives a notice if the chapter was already posted and redirects to the posted chapter" do
            put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes, post_button: true }
            it_redirects_to_with_notice(work_chapter_path(work_id: work.id, id: work.chapters.first.id), "Chapter was successfully updated.")
          end

          it "gives a notice if the chapter was not already posted and redirects to the posted chapter" do
            unposted_chapter = create(:chapter, work: work, authors: [user.pseuds.first])
            put :update, params: { work_id: work.id, id: unposted_chapter.id, chapter: @chapter_attributes, post_button: true }
            it_redirects_to_with_notice(work_chapter_path(work_id: work.id, id: unposted_chapter.id), "Chapter was successfully posted.")
          end
        end

        context "when the chapter or work is not valid" do
          it "does not update the chapter" do
            put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: { content: "" }, post_button: true }
            expect(assigns[:chapter]).to eq work.chapters.first
          end

          it "renders edit" do
            put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: { content: "" }, post_button: true }
            expect(response).to render_template(:edit)
          end
        end

        it "updates the work's revision date" do
          Delorean.time_travel_to("1 day ago") do
            work.touch
          end

          old_updated_at = work.updated_at

          put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes, post_button: true }
          expect(assigns[:work].updated_at).not_to eq(old_updated_at)
        end
      end

      context "when the post without preview button is clicked" do
        it "posts the chapter" do
          put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes, post_without_preview_button: true }
          expect(assigns[:chapter].posted).to be true
        end
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      context "when the user tries to add themselves as a coauthor" do
        before do
          @chapter_attributes[:author_attributes] = { ids: [user.pseuds.first.id, @current_user.pseuds.first.id] }
        end

        it "errors and redirects to work" do
          put :update, params: { work_id: work.id, id: work.chapters.first.id, chapter: @chapter_attributes }
          it_redirects_to_with_error(work_path(work), "Sorry, you don't have permission to access the page you were trying to reach.")
        end
      end
    end
  end

  describe "update_positions" do
    before do
      @chapter1 = work.chapters.first
      @chapter2 = create(:chapter, work: work, posted: true, position: 2, authors: [user.pseuds.first])
      @chapter3 = create(:chapter, work: work, posted: true, position: 3, authors: [user.pseuds.first])
    end

    context "when user is logged out" do
      it "errors and redirects to login" do
        post :update_positions, params: { work_id: work.id, chapter: [@chapter1, @chapter3, @chapter2] }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      context "when passing params[:chapters]" do
        it "updates the positions of the chapters" do
          post :update_positions, params: { work_id: work.id, chapters: [1, 3, 2] }
          expect(@chapter1.reload.position).to eq(1)
          expect(@chapter2.reload.position).to eq(3)
          expect(@chapter3.reload.position).to eq(2)
        end

        it "gives a notice and redirects to work" do
          post :update_positions, params: { work_id: work.id, chapters: [1, 3, 2] }
          it_redirects_to_with_notice(work, "Chapter order has been successfully updated.")
        end
      end

      context "when passing params[:chapter]" do
        it "updates the positions of the chapters" do
          post :update_positions, params: { work_id: work.id, chapter: [@chapter1, @chapter3, @chapter2], format: :js }
          expect(@chapter1.reload.position).to eq(1)
          expect(@chapter2.reload.position).to eq(3)
          expect(@chapter3.reload.position).to eq(2)
        end
      end
    end
  end

  describe "preview" do
    context "when user is logged out" do
      it "errors and redirects to login" do
        get :preview, params: { work_id: work.id, id: work.chapters.first.id }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "renders preview template" do
        get :preview, params: { work_id: work.id, id: work.chapters.first.id }
        expect(response).to render_template(:preview)
      end

      it "assigns instance variables correctly" do
        get :preview, params: { work_id: work.id, id: work.chapters.first.id }
        expect(assigns[:work]).to eq work
        expect(assigns[:chapter]).to eq work.chapters.first
        expect(assigns[:allpseuds]).to eq user.pseuds
        expect(assigns[:pseuds]).to eq user.pseuds
        expect(assigns[:coauthors]).to eq []
        expect(assigns[:selected_pseuds]).to eq [user.pseuds.first.id]
        expect(assigns[:preview_mode]).to be true
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      it "errors and redirects to work" do
        get :preview, params: { work_id: work.id, id: work.chapters.first.id }
        it_redirects_to_with_error(work_path(work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "post" do
    before do
      @chapter_to_post = create(:chapter, work: work, authors: [user.pseuds.first], position: 2)
    end

    context "when user is logged out" do
      it "errors and redirects to login" do
        post :post, params: { work_id: work.id, id: @chapter_to_post.id }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "redirects to work when cancel button is clicked" do
        post :post, params: { work_id: work.id, id: @chapter_to_post.id, cancel_button: true }
        it_redirects_to(work)
      end

      it "redirects to edit when edit button is clicked" do
        post :post, params: { work_id: work.id, id: @chapter_to_post.id, edit_button: true }
        it_redirects_to(edit_work_chapter_path(work_id: work.id, id: @chapter_to_post.id))
      end

      context "when the chapter and work are valid" do
        it "posts the chapter and redirects to work" do
          post :post, params: { work_id: work.id, id: @chapter_to_post.id }
          expect(assigns[:chapter].posted).to be true
          it_redirects_to_with_notice(work, "Chapter has been posted!")
        end

        it "posts the work if the work was not posted before" do
          post :post, params: { work_id: unposted_work.id, id: unposted_work.chapters.first.id }
          expect(assigns[:work].posted).to be true
        end
      end

      context "when the chapter or work is not valid" do
        before do
          allow_any_instance_of(Chapter).to receive(:save).and_return(false)
        end

        it "does not update the chapter" do
          post :post, params: { work_id: work.id, id: @chapter_to_post.id }
          expect(assigns[:chapter]).to eq @chapter_to_post
        end

        it "renders preview" do
          post :post, params: { work_id: work.id, id: @chapter_to_post.id }
          expect(response).to render_template(:preview)
        end
      end

      it "updates the work's revision date" do
        Delorean.time_travel_to("1 day ago") do
          work.touch
        end

        old_updated_at = work.updated_at

        post :post, params: { work_id: work.id, id: @chapter_to_post.id }
        expect(assigns[:work].updated_at).not_to eq(old_updated_at)
      end

      it "assigns instance variables correctly" do
        post :post, params: { work_id: work.id, id: @chapter_to_post.id }
        expect(assigns[:allpseuds]).to eq user.pseuds
        expect(assigns[:pseuds]).to eq user.pseuds
        expect(assigns[:coauthors]).to eq []
        expect(assigns[:selected_pseuds]).to eq [user.pseuds.first.id]
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      it "errors and redirects to work" do
        pending "non-work owner should not be able to post works"
        post :post, params: { work_id: work.id, id: @chapter_to_post.id }
        it_redirects_to_with_error(work_path(work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "confirm_delete" do
    context "when user is logged out" do
      it "errors and redirects to work" do
        get :confirm_delete, params: { work_id: work.id, id: work.chapters.first.id }
        it_redirects_to_with_error(work_path(work), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      it "renders confirm delete template" do
        get :confirm_delete, params: { work_id: work.id, id: work.chapters.first.id }
        expect(response).to render_template(:confirm_delete)
      end

      it "assigns instance variables correctly" do
        get :confirm_delete, params: { work_id: work.id, id: work.chapters.first.id }
        expect(assigns[:work]).to eq work
        expect(assigns[:chapter]).to eq work.chapters.first
        expect(assigns[:allpseuds]).to eq user.pseuds
        expect(assigns[:pseuds]).to eq user.pseuds
        expect(assigns[:coauthors]).to eq []
        expect(assigns[:selected_pseuds]).to eq [user.pseuds.first.id]
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      it "errors and redirects to work" do
        get :confirm_delete, params: { work_id: work.id, id: work.chapters.first.id }
        it_redirects_to_with_error(work_path(work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "destroy" do
    context "when user is logged out" do
      it "errors and redirects to login" do
        pending "clean up chapter filters"
        delete :destroy, params: { work_id: work.id, id: work.chapters.first.id }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when work owner is logged in" do
      before do
        fake_login_known_user(user)
      end

      context "when work has one chapter" do
        it "redirects to edit work" do
          delete :destroy, params: { work_id: work.id, id: work.chapters.first.id }
          it_redirects_to_with_error(edit_work_path(work), "You can't delete the only chapter in your story. If you want to delete the story, choose 'Delete work'.")
        end
      end

      context "when work has more than one chapter" do
        before do
          @chapter2 = create(:chapter, work: work, posted: true, position: 2, authors: [user.pseuds.first])
        end

        it "updates the work's minor version" do
          expect(work.minor_version).to eq(0)
          delete :destroy, params: { work_id: work.id, id: @chapter2.id }
          expect(assigns[:work].minor_version).to eq(1)
        end

        it "updates the work's revision date" do
          Delorean.time_travel_to("1 day ago") do
            work.touch
          end

          old_updated_at = work.updated_at

          delete :destroy, params: { work_id: work.id, id: @chapter2.id }
          expect(assigns[:work].updated_at).not_to eq(old_updated_at)
        end

        it "gives a notice that the chapter was deleted and redirects to work" do
          delete :destroy, params: { work_id: work.id, id: @chapter2.id }
          it_redirects_to_with_notice(work, "The chapter was successfully deleted.")
        end

        it "gives a notice that the draft chapter was deleted if the chapter was a draft and redirects to work" do
          @chapter2.posted = false
          @chapter2.save
          delete :destroy, params: { work_id: work.id, id: @chapter2.id }
          it_redirects_to_with_notice(work, "The chapter draft was successfully deleted.")
        end

        it "errors and redirects to work when chapter is not deleted" do
          allow_any_instance_of(Chapter).to receive(:destroy).and_return(false)
          delete :destroy, params: { work_id: work.id, id: @chapter2.id }
          it_redirects_to_with_error(work, "Something went wrong. Please try again.")
        end
      end
    end

    context "when other user is logged in" do
      before do
        fake_login
      end

      it "errors and redirects to work" do
        delete :destroy, params: { work_id: work.id, id: work.chapters.first.id }
        it_redirects_to_with_error(work_path(work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end
end
