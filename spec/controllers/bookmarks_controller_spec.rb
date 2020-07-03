require "spec_helper"

describe BookmarksController do
  include LoginMacros
  include RedirectExpectationHelper

  def it_redirects_to_user_login
    it_redirects_to_simple new_user_session_path
  end

  describe "new" do
    context "without javascript" do
      it "redirects anyone not logged in" do
        get :new
        it_redirects_to_user_login
      end

      it "renders the new form template if logged in" do
        fake_login
        get :new
        expect(response).to render_template("new")
      end
    end

    context "with javascript" do
      it "renders the bookmark_form_dynamic form if logged in" do
        fake_login
        get :new, params: { format: :js }, xhr: true
        expect(response).to render_template("bookmark_form_dynamic")
      end
    end
  end

  describe "edit" do
    context "with javascript" do
      let(:bookmark) { FactoryBot.create(:bookmark) }

      it "renders the bookmark_form_dynamic form if logged in" do
        fake_login_known_user(bookmark.pseud.user)
        get :edit, params: { id: bookmark.id, format: :js }, xhr: true
        expect(response).to render_template("bookmark_form_dynamic")
      end
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
end
