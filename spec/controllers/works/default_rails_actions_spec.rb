# frozen_string_literal: true
require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "before_action #clean_work_search_params" do
    let(:params) { {} }

    def call_with_params(params)
      controller.params = { work_search: params }
      controller.params[:work_search] = controller.clean_work_search_params
    end

    context "when no work search parameters are given" do
      it "redirects to the login screen when no user is logged in" do
        get :clean_work_search_params, params: params
        it_redirects_to_with_error(new_user_session_path,
                                   "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when the query contains countable search parameters" do
      it "escapes less and greater than in query" do
        [
          { params: "< 5 words", expected: "&lt; 5 words", message: "Should escape <" },
          { params: "> 5 words", expected: "&gt; 5 words", message: "Should escape >" },
        ].each do |settings|
          call_with_params(query: settings[:params])
          expect(controller.params[:work_search][:query])
            .to eq(settings[:expected]), settings[:message]
        end
      end

      it "converts 'word' to 'word_count'" do
        call_with_params(query: "word:6")
        expect(controller.params[:work_search][:word_count]).to eq("6")
      end

      it "converts 'words' to 'word_count'" do
        call_with_params(query: "words:7")
        expect(controller.params[:work_search][:word_count]).to eq("7")
      end

      it "converts 'hits' queries to 'hits'" do
        call_with_params(query: "hits:8")
        expect(controller.params[:work_search][:hits]).to eq("8")
      end

      it "converts other queries to (pluralized term)_count" do
        %w(kudo comment bookmark).each do |term|
          call_with_params(query: "#{term}:9")
          expect(controller.params[:work_search]["#{term.pluralize}_count"])
            .to eq("9"), "Search term '#{term}' should become #{term.pluralize}_count key"
        end
      end
    end

    context "when sort parameters are provided" do
      it "converts variations on 'sorted by: X' into :sort_column key" do
        [
          "sort by: words",
          "sorted by: words",
          "sorted: words",
          "sort: words",
          "sort by < words",
          "sort by > words",
          "sort by = words"
        ].each do |query|
          call_with_params(query: query)
          expect(controller.params[:work_search][:sort_column])
            .to eq("word_count"), "Sort command '#{query}' should be converted to :sort_column"
        end
      end

      it "converts variations on sort columns to column name" do
        [
          { query: "sort by: word count", expected: "word_count" },
          { query: "sort by: words", expected: "word_count" },
          { query: "sort by: word", expected: "word_count" },
          { query: "sort by: author", expected: "authors_to_sort_on" },
          { query: "sort by: title", expected: "title_to_sort_on" },
          { query: "sort by: date", expected: "created_at" },
          { query: "sort by: date posted", expected: "created_at" },
          { query: "sort by: hits", expected: "hits" },
          { query: "sort by: kudos", expected: "kudos_count" },
          { query: "sort by: comments", expected: "comments_count" },
          { query: "sort by: bookmarks", expected: "bookmarks_count" },
        ].each do |settings|
          call_with_params(query: settings[:query])
          actual = controller.params[:work_search][:sort_column]
          expect(actual)
            .to eq(settings[:expected]),
                "Query '#{settings[:query]}' should be converted to :sort_column '#{settings[:expected]}' but is '#{actual}'"
        end
      end

      it "converts 'ascending' or '>' into :sort_direction key 'asc'" do
        [
          "sort > word_count",
          "sort: word_count ascending",
          "sort: hits ascending",
        ].each do |query|
          call_with_params(query: query)
          expect(controller.params[:work_search][:sort_direction]).to eq("asc")
        end
      end

      it "converts 'descending' or '<' into :sort_direction key 'desc'" do
        [
          "sort < word_count",
          "sort: word_count descending",
          "sort: hits descending",
        ].each do |query|
          call_with_params(query: query)
          expect(controller.params[:work_search][:sort_direction]).to eq("desc")
        end
      end

      # The rest of these are probably bugs
      it "returns no sort column if there is NO punctuation after 'sort by' clause" do
        call_with_params(query: "sort by word count")
        expect(controller.params[:work_search][:sort_column]).to be_nil
      end

      it "can't search by date updated" do
        [
          { query: "sort by: date updated", expected: "revised_at" },
        ].each do |settings|
          call_with_params(query: settings[:query])
          expect(controller.params[:work_search][:sort_column]).to eq("created_at") # should be revised_at
        end
      end

      it "can't sort ascending if more than one word follows the colon" do
        [
          "sort by: word count ascending",
        ].each do |query|
          call_with_params(query: query)
          expect(controller.params[:work_search][:sort_direction]).to be_nil
        end
      end
    end

    context "when the query contains categories" do
      it "surrounds categories in quotes" do
        [
          { query: "M/F sort by: comments", expected: "\"m/f\"" },
          { query: "f/f Scully/Reyes", expected: "\"f/f\" Scully/Reyes" },
        ].each do |settings|
          call_with_params(query: settings[:query])
          expect(controller.params[:work_search][:query]).to eq(settings[:expected])
        end
      end

      it "does not surround categories in quotes when it shouldn't" do
        query = "sam/frodo sort by: word"
        call_with_params(query: query)
        expect(controller.params[:work_search][:query]).to eq("sam/frodo")
      end
    end
  end

  describe "new" do
    it "doesn't return the form for anyone not logged in" do
      get :new
      it_redirects_to_with_error(new_user_session_path,
                                 "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    it "renders the form if logged in" do
      fake_login
      get :new
      expect(response).to render_template("new")
    end
  end

  describe "create" do
    before do
      @user = create(:user)
      fake_login_known_user(@user)
    end

    it "doesn't allow a user to submit only a pseud that is not theirs" do
      @user2 = create(:user)
      work_attributes = attributes_for(:work)
      work_attributes[:author_attributes] = { ids: [@user2.pseuds.first.id] }
      expect {
        post :create, params: { work: work_attributes }
      }.to_not change(Work, :count)
      expect(response).to render_template("new")
      expect(flash[:error]).to eq "You're not allowed to use that pseud."
    end

    it "renders the co-author view if a work has invalid pseuds" do
      allow_any_instance_of(Work).to receive(:invalid_pseuds).and_return(@user.pseuds.first)
      work_attributes = attributes_for(:work)
      post :create, params: { work: work_attributes }
      expect(response).to render_template("_choose_coauthor")
      allow_any_instance_of(Work).to receive(:invalid_pseuds).and_call_original
    end

    it "renders the co-author view if a work has ambiguous pseuds" do
      allow_any_instance_of(Work).to receive(:ambiguous_pseuds).and_return(@user.pseuds.first)
      work_attributes = attributes_for(:work)
      post :create, params: { work: work_attributes }
      expect(response).to render_template("_choose_coauthor")
      allow_any_instance_of(Work).to receive(:ambiguous_pseuds).and_call_original
    end
  end

  describe "show" do
    it "doesn't error when a work has no fandoms" do
      work = create(:posted_work, fandoms: [])
      fake_login
      get :show, params: { id: work.id }
      expect(assigns(:page_title)).to include "No fandom specified"
    end
  end

  describe "index" do
    before do
      @fandom = create(:canonical_fandom)
      @work = create(:posted_work, fandom_string: @fandom.name)
    end

    it "returns the work" do
      get :index
      expect(assigns(:works)).to include(@work)
    end

    it "sets the fandom when given a fandom id" do
      params = { fandom_id: @fandom.id }
      get :index, params: params
      expect(assigns(:fandom)).to eq(@fandom)
    end

    it "returns search results when given work_search parameters" do
      params = { :work_search => { query: "fandoms: #{@fandom.name}" } }
      get :index, params: params
      expect(assigns(:works)).to include(@work)
    end

    describe "without caching" do
      before do
        allow(controller).to receive(:use_caching?).and_return(false)
      end

      it "returns the result with different works the second time" do
        get :index
        expect(assigns(:works)).to include(@work)
        work2 = create(:posted_work)
        get :index
        expect(assigns(:works)).to include(work2)
      end
    end

    describe "with caching" do
      before do
        allow(controller).to receive(:use_caching?).and_return(true)
      end

      context "with NO owner tag" do
        it "returns the same result the second time when a new work is created within the expiration time" do
          get :index
          expect(assigns(:works)).to include(@work)
          work2 = create(:posted_work)
          update_and_refresh_indexes('work')
          get :index
          expect(assigns(:works)).not_to include(work2)
        end
      end

      context "with a valid owner tag" do
        before do
          @fandom2 = create(:canonical_fandom)
          @work2 = create(:posted_work, fandom_string: @fandom2.name)

          update_and_refresh_indexes('work')
        end

        it "only gets works under that tag" do
          get :index, params: { tag_id: @fandom.name }
          expect(assigns(:works).items).to include(@work)
          expect(assigns(:works).items).not_to include(@work2)
        end

        it "shows different results on second page" do
          get :index, params: { tag_id: @fandom.name, page: 2 }
          expect(assigns(:works).items).not_to include(@work)
        end

        it "shows results when filters are disabled" do
          allow(controller).to receive(:fetch_admin_settings).and_return(true)
          admin_settings = AdminSetting.new(disable_filtering: true)
          controller.instance_variable_set("@admin_settings", admin_settings)
          get :index, params: { tag_id: @fandom.name }
          expect(assigns(:works)).to include(@work)

          allow(controller).to receive(:fetch_admin_settings).and_call_original
        end

        context "with restricted works" do
          before do
            @work2 = create(:posted_work, fandom_string: @fandom.name, restricted: true)
            update_and_refresh_indexes('work')
          end

          it "shows restricted works to guests" do
            get :index, params: { tag_id: @fandom.name }
            expect(assigns(:works).items).to include(@work)
            expect(assigns(:works).items).not_to include(@work2)
          end

        end

        context "when tag is a synonym" do
          let(:fandom_synonym) { create(:fandom, merger: @fandom) }

          it "redirects to the merger's work index" do
            params = { tag_id: fandom_synonym.name }
            get :index, params: params
            it_redirects_to tag_works_path(@fandom)
          end

          context "when collection is specified" do
            let(:collection) { create(:collection) }

            it "redirects to the merger's collection works index" do
              params = { tag_id: fandom_synonym.name, collection_id: collection.name }
              get :index, params: params
              it_redirects_to collection_tag_works_path(collection, @fandom)
            end
          end
        end
      end
    end

    context "with an invalid owner tag" do
      it "raises an error" do
        params = { tag_id: "nonexistent_tag" }
        expect { get :index, params: params }.to raise_error(
          ActiveRecord::RecordNotFound,
          "Couldn't find tag named 'nonexistent_tag'"
        )
      end
    end

    context "with an invalid owner user" do
      it "raises an error" do
        params = { user_id: "nonexistent_user" }
        expect { get :index, params: params }.to raise_error(
          ActiveRecord::RecordNotFound
        )
      end

      context "with an invalid pseud" do
        it "raises an error" do
          params = { user_id: "nonexistent_user", pseud_id: "nonexistent_pseud" }
          expect { get :index, params: params }.to raise_error(
            ActiveRecord::RecordNotFound
          )
        end
      end
    end

    context "with a valid owner user" do
      let(:user) { create(:user) }
      let!(:user_work) { create(:posted_work, authors: [user.default_pseud]) }
      let(:pseud) { create(:pseud, user: user) }
      let!(:pseud_work) { create(:posted_work, authors: [pseud]) }

      before do
        update_and_refresh_indexes("work")
      end

      it "includes only works for that user" do
        params = { user_id: user.login }
        get :index, params: params
        expect(assigns(:works).items).to include(user_work, pseud_work)
        expect(assigns(:works).items).not_to include(@work)
      end

      context "with a valid pseud" do
        it "includes only works for that pseud" do
          params = { user_id: user.login, pseud_id: pseud.name }
          get :index, params: params
          expect(assigns(:works).items).to include(pseud_work)
          expect(assigns(:works).items).not_to include(user_work, @work)
        end
      end

      context "with an invalid pseud" do
        it "includes all of that user's works" do
          params = { user_id: user.login, pseud_id: "nonexistent_pseud" }
          get :index, params: params
          expect(assigns(:works).items).to include(user_work, pseud_work)
          expect(assigns(:works).items).not_to include(@work)
        end
      end
    end
  end

  describe "update" do
    let(:update_user) { create(:user) }
    let(:update_chapter) { create(:chapter) }
    let(:update_work) {
      work = create(:posted_work, authors: [update_user.default_pseud])
      work.chapters << update_chapter
      work
    }

    before do
      fake_login_known_user(update_user)
    end

    it "redirects to the edit page if the work could not be saved" do
      allow_any_instance_of(Work).to receive(:save).and_return(false)
      update_work.fandom_string = "Testing"
      attrs = { title: "New Work Title" }
      put :update, params: { id: update_work.id, work: attrs }
      expect(response).to render_template :edit
      allow_any_instance_of(Work).to receive(:save).and_call_original
    end

    context "where the coauthor is being updated" do
      let(:new_coauthor) { create(:user) }
      let(:params) do
        {
          work: { title: "New title" },
          pseud: { byline: new_coauthor.login },
          id: update_work.id
        }
      end
      it "updates coauthors for each chapter when the work is updated" do
        put :update, params: params
        updated_work = Work.find(update_work.id)
        expect(updated_work.pseuds).to include new_coauthor.default_pseud
        updated_work.chapters.each do |c|
          expect(c.pseuds).to include new_coauthor.default_pseud
        end
      end
    end
  end

  describe "collected" do
    let(:collection) { create(:collection) }
    let(:collected_user) { create(:user) }

    context "with anonymous works" do
      let(:anonymous_collection) { create(:anonymous_collection) }

      let!(:work) do
        create(:posted_work,
               authors: [collected_user.default_pseud],
               collection_names: collection.name)
      end

      let!(:anonymous_work) do
        create(:posted_work,
               authors: [collected_user.default_pseud],
               collection_names: anonymous_collection.name)
      end

      before { update_and_refresh_indexes "work" }

      it "does not return anonymous works in collections for guests" do
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work)
        expect(assigns(:works)).not_to include(anonymous_work)
      end

      it "does not return anonymous works in collections for logged-in users" do
        fake_login
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work)
        expect(assigns(:works)).not_to include(anonymous_work)
      end

      it "returns anonymous works in collections for the author" do
        fake_login_known_user(collected_user)
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work, anonymous_work)
      end
    end

    context "with restricted works" do
      let(:collected_fandom) { create(:canonical_fandom) }
      let(:collected_fandom_2) { create(:canonical_fandom) }

      let!(:unrestricted_work) do
        create(:posted_work,
               authors: [collected_user.default_pseud],
               fandom_string: collected_fandom.name)
      end

      let!(:unrestricted_work_in_collection) do
        create(:posted_work,
               authors: [collected_user.default_pseud],
               collection_names: collection.name,
               fandom_string: collected_fandom.name)
      end

      let!(:unrestricted_work_2_in_collection) do
        create(:posted_work,
               authors: [collected_user.default_pseud],
               collection_names: collection.name,
               fandom_string: collected_fandom_2.name)
      end

      let!(:restricted_work_in_collection) do
        create(:posted_work,
               restricted: true,
               authors: [collected_user.default_pseud],
               collection_names: collection.name,
               fandom_string: collected_fandom.name)
      end

      before { update_and_refresh_indexes "work" }

      context "as a guest" do
        it "renders the empty collected form" do
          get :collected
          expect(response).to render_template("collected")
        end

        it "does NOT return any works if no user is set" do
          get :collected
          expect(assigns(:works)).to be_nil
        end

        it "returns ONLY unrestricted works in collections" do
          get :collected, params: { user_id: collected_user.login }
          expect(assigns(:works)).to include(unrestricted_work_in_collection, unrestricted_work_2_in_collection)
          expect(assigns(:works)).not_to include(unrestricted_work, restricted_work_in_collection)
        end

        it "returns filtered works when search parameters are provided" do
          get :collected, params: { user_id: collected_user.login, work_search: { query: "fandom_ids:#{collected_fandom_2.id}" }}
          expect(assigns(:works)).to include(unrestricted_work_2_in_collection)
          expect(assigns(:works)).not_to include(unrestricted_work_in_collection)
        end
      end

      context "with a logged-in user" do
        before { fake_login }

        it "returns ONLY works in collections" do
          get :collected, params: { user_id: collected_user.login }
          expect(assigns(:works)).to include(unrestricted_work_in_collection, restricted_work_in_collection)
          expect(assigns(:works)).not_to include(unrestricted_work)
        end
      end
    end

    context "with unrevealed works" do
      let(:unrevealed_collection) { create(:unrevealed_collection) }

      let!(:work) do
        create(:posted_work,
               authors: [collected_user.default_pseud],
               collection_names: collection.name)
      end

      let!(:unrevealed_work) do
        create(:posted_work,
               authors: [collected_user.default_pseud],
               collection_names: unrevealed_collection.name)
      end

      before { update_and_refresh_indexes "work" }

      it "returns unrevealed works in collections for guests" do
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work, unrevealed_work)
      end

      it "returns unrevealed works in collections for logged-in users" do
        fake_login
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work, unrevealed_work)
      end
    end
  end
end
