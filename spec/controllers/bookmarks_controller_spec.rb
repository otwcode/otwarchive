require "spec_helper"

describe BookmarksController do
  include LoginMacros
  include RedirectExpectationHelper

  def it_redirects_to_user_login
    it_redirects_to_simple new_user_session_path
  end

  describe "new" do
    context "without javascript" do
      let(:chaptered_work) { create(:work) }
      let(:chapter2) { create(:chapter, work: chaptered_work) }
      let(:bookmark) { create(:bookmark, bookmarkable_id: chaptered_work.id) }

      it "redirects logged out users" do
        get :new
        it_redirects_to_user_login
      end
      
      context "when logged in" do
        it "renders the new form template" do
          fake_login
          get :new
          expect(response).to render_template("new")
        end

        it "renders the new form for a multi-chapter work" do
          fake_login
          get :new, params: { chapter_id: chapter2.id }
          expect(response).to render_template("new")
          expect(assigns(:bookmarkable)).to eq(chaptered_work)
        end
      end
    end

    context "with javascript when logged in" do
      let(:chaptered_work) { create(:work) }
      let(:chapter2) { create(:chapter, work: chaptered_work) }
      let(:bookmark) { create(:bookmark, bookmarkable_id: chaptered_work.id) }

      it "renders the bookmark_form_dynamic form" do
        fake_login
        get :new, params: { format: :js }, xhr: true
        expect(response).to render_template("bookmark_form_dynamic")
      end

      it "renders the new form for a bookmark on a multi-chapter work" do
        fake_login
        get :new, params: { chapter_id: chapter2.id, format: :js }, xhr: true
        expect(response).to render_template("bookmark_form_dynamic")
        expect(assigns(:bookmarkable)).to eq(chaptered_work)
      end
    end
  end

  describe "edit" do
    context "with javascript" do
      let(:bookmark) { create(:bookmark) }

      it "renders the bookmark_form_dynamic form if logged in" do
        fake_login_known_user(bookmark.pseud.user)
        get :edit, params: { id: bookmark.id, format: :js }, xhr: true
        expect(response).to render_template("bookmark_form_dynamic")
      end
    end
  end

  describe "share" do
    it "returns correct response for bookmark to revealed work" do
      bookmark = create :bookmark
      # Assert this bookmark is of an revealed work
      expect(bookmark.bookmarkable.unrevealed?).to eq(false)

      fake_login_known_user(bookmark.pseud.user)
      get :share, params: { id: bookmark.id }, xhr: true
      expect(response.status).to eq(200)
      expect(response).to render_template("bookmarks/share")
    end

    it "returns a 404 response for bookmark to unrevealed work" do
      unrevealed_collection = create :unrevealed_collection
      unrevealed_work = create :work, collections: [unrevealed_collection]
      unrevealed_bookmark = create :bookmark, bookmarkable_id: unrevealed_work.id
      # Assert this bookmark is of an unrevealed work
      expect(unrevealed_bookmark.bookmarkable.unrevealed?).to eq(true)

      fake_login_known_user(unrevealed_bookmark.pseud.user)
      get :share, params: { id: unrevealed_bookmark.id }, xhr: true
      expect(response.status).to eq(404)
    end

    it "redirects to referer with an error for non-ajax warnings requests" do
      bookmark = create(:bookmark)

      fake_login_known_user(bookmark.pseud.user)
      get :share, params: { id: bookmark.id }
      it_redirects_to_with_error(root_path, "Sorry, you need to have JavaScript enabled for this.")
    end
  end

  describe "index" do
    let!(:external_work_bookmark) { create(:external_work_bookmark) }
    let!(:series_bookmark) { create(:series_bookmark) }
    let!(:work_bookmark) { create(:bookmark) }

    context "with chapter_id parameters" do
      it "loads the work as the bookmarkable" do
        params = { chapter_id: work_bookmark.bookmarkable.chapters.first.id }
        get :index, params: params
        expect(assigns(:bookmarkable)).to eq(work_bookmark.bookmarkable)
      end
    end

    context "with external_work_id parameters" do
      it "loads the external work as the bookmarkable" do
        params = { external_work_id: external_work_bookmark.bookmarkable.id }
        get :index, params: params
        expect(assigns(:bookmarkable)).to eq(external_work_bookmark.bookmarkable)
      end
    end

    context "with user_id parameters" do
      context "when user_id does not exist" do
        it "raises a RecordNotFound error" do
          params = { user_id: "nobody" }
          expect { get :index, params: params }.to raise_error(
            ActiveRecord::RecordNotFound,
            "Couldn't find user named 'nobody'"
          )
        end
      end

      context "when user_id exists" do
        context "when pseud_id does not exist" do
          it "raises a RecordNotFound error for the pseud" do
            params = { user_id: work_bookmark.pseud.user, pseud_id: "nobody" }
            expect { get :index, params: params }.to raise_error(
              ActiveRecord::RecordNotFound,
              "Couldn't find pseud named 'nobody'"
            )
          end
        end
      end
    end

    context "with tag_id parameters" do
      let(:tag) { create(:fandom) }
      let(:merger) { create(:fandom, merger_id: canonical.id) }
      let(:canonical) { create(:canonical_fandom) } 

      context "when tag_id does not exist" do
        it "raises a RecordNotFound error" do
          params = { tag_id: "nothingness" }
          expect { get :index, params: params }.to raise_error(
            ActiveRecord::RecordNotFound,
            "Couldn't find tag named 'nothingness'"
          )
        end
      end

      context "when tag_id is not canonical" do
        context "when tag_id is a synonym" do
          it "redirects to the canonical's tag_bookmarks_path" do
            params = { tag_id: merger }
            get :index, params: params
            expect(response).to redirect_to(tag_bookmarks_path(canonical))
          end
        end

        context "when tag_id is not a synonym" do
          it "redirects to tag_path" do
            params = { tag_id: tag }
            get :index, params: params
            expect(response).to redirect_to(tag_path(tag))
          end
        end
      end
    end

    context "without caching" do
      before do
        AdminSetting.first.update_attribute(:enable_test_caching, false)
      end

      it "returns work bookmarks" do
        get :index
        expect(assigns(:bookmarks)).to include(work_bookmark)
      end

      it "does not return external work bookmarks" do
        get :index
        expect(assigns(:bookmarks)).not_to include(external_work_bookmark)
      end

      it "does not return series bookmarks" do
        get :index
        expect(assigns(:bookmarks)).not_to include(series_bookmark)
      end

      it "returns the result with new bookmarks the second time" do
        get :index
        expect(assigns(:bookmarks)).to include(work_bookmark)
        work_bookmark2 = create(:bookmark)
        get :index
        expect(assigns(:bookmarks)).to include(work_bookmark)
        expect(assigns(:bookmarks)).to include(work_bookmark2)
      end
    end

    context "with caching", bookmark_search: true do
      before do
        AdminSetting.first.update_attribute(:enable_test_caching, true)
        run_all_indexing_jobs
      end

      it "returns work bookmarks" do
        get :index
        expect(assigns(:bookmarks)).to include(work_bookmark)
      end

      it "returns external work bookmarks" do
        get :index
        expect(assigns(:bookmarks)).to include(external_work_bookmark)
      end

      it "returns series bookmarks" do
        get :index
        expect(assigns(:bookmarks)).to include(series_bookmark)
      end

      it "returns the same result the second time when a new bookmark is created within the expiration time" do
        get :index
        expect(assigns(:bookmarks)).to include(external_work_bookmark)
        expect(assigns(:bookmarks)).to include(series_bookmark)
        expect(assigns(:bookmarks)).to include(work_bookmark)
        work_bookmark2 = create(:bookmark)
        run_all_indexing_jobs
        get :index
        expect(assigns(:bookmarks)).to include(external_work_bookmark)
        expect(assigns(:bookmarks)).to include(series_bookmark)
        expect(assigns(:bookmarks)).to include(work_bookmark)
        expect(assigns(:bookmarks)).not_to include(work_bookmark2)
      end
    end
  end

  describe "show" do
    let(:chaptered_work) { create(:work, title: "Cool title") }
    let(:chapter2) { create(:chapter, work: chaptered_work, position: 2, posted: true, title: "Second title") }
    let(:bookmark) { create(:bookmark, bookmarkable_id: chaptered_work.id) }

    context "when logged in" do
      it "returns a bookmark on a public multi-chapter work" do
        fake_login_known_user(bookmark.pseud.user)
        get :show, params: { id: bookmark }
        expect(response).to have_http_status(:success)
        expect(assigns(:bookmark)).to eq(bookmark)
      end
    end
  end
end
