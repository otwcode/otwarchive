require 'spec_helper'

describe WorksController do
  include LoginMacros

  def it_redirects_to_user_login
    expect(response).to have_http_status(:redirect)
    expect(response).to redirect_to new_user_session_path
  end

  describe "before_filter #clean_work_search_params" do
    let(:params) { nil }

    def call_with_params(params)
      controller.params = { work_search: params }
      controller.clean_work_search_params
    end

    context "when no work search parameters are given" do
      it "redirects to the login screen when no user is logged in" do
        get :clean_work_search_params, params
        it_redirects_to_user_login
      end

      it "returns a nil" do
        fake_login
        controller.params = params
        controller.clean_work_search_params
        expect(controller.params[:work_search]).to be_nil
      end
    end

    context "when search parameters are empty" do
      let(:params) { [] }

      it "returns a RecordNotFound exception" do
        call_with_params params
        expect(controller.params[:work_search]).to be_empty
      end
    end

    context "when the query contains countable search parameters" do
      it "should escape less and greater than in query" do
        [
          { params: "< 5 words", expected: "&lt; 5 words", message: "Should escape <" },
          { params: "> 5 words", expected: "&gt; 5 words", message: "Should escape >" },
        ].each do |settings|
          call_with_params(query: settings[:params])
          expect(controller.params[:work_search][:query])
            .to eq(settings[:expected]), settings[:message]
        end
      end

      it "should convert 'word' to 'word_count'" do
        call_with_params(query: "word:6")
        expect(controller.params[:work_search][:word_count]).to eq("6")
      end

      it "should convert 'words' to 'word_count'" do
        call_with_params(query: "words:7")
        expect(controller.params[:work_search][:word_count]).to eq("7")
      end

      it "should convert 'hits' queries to 'hits'" do
        call_with_params(query: "hits:8")
        expect(controller.params[:work_search][:hits]).to eq("8")
      end

      it "should convert other queries to (pluralized term)_count" do
        %w(kudo comment bookmark).each do |term|
          call_with_params(query: "#{term}:9")
          expect(controller.params[:work_search]["#{term.pluralize}_count"])
            .to eq("9"), "Search term '#{term}' should become #{term.pluralize}_count key"
        end
      end
    end

    context "when sort parameters are provided" do
      it "should convert variations on 'sorted by: X' into :sort_column key" do
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

      it "should convert variations on sort columns to column name" do
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

      it "should convert 'ascending' or '>' into :sort_direction key 'asc'" do
        [
          "sort > word_count",
          "sort: word_count ascending",
          "sort: hits ascending",
        ].each do |query|
          call_with_params(query: query)
          expect(controller.params[:work_search][:sort_direction]).to eq("asc")
        end
      end

      it "should convert 'descending' or '<' into :sort_direction key 'desc'" do
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
          { query: "M/F sort by: comments", expected: "M/F " },
          { query: "f/f Scully/Reyes", expected: "\"f/f\" Scully/Reyes" },
        ].each do |settings|
          call_with_params(query: settings[:query])
          expect(controller.params[:work_search][:query]).to eq(settings[:expected])
        end
      end

      it "surrounds categories in quotes even when it shouldn't (AO3-3576)" do
        query = "sam/frodo sort by: word"
        call_with_params(query: query)
        expect(controller.params[:work_search][:query]).to eq("sa\"m/f\"rodo ")
      end
    end
  end

  describe "new" do
    it "should not return the form for anyone not logged in" do
      get :new
      it_redirects_to_user_login
    end

    it "should render the form if logged in" do
      fake_login
      get :new
      expect(response).to render_template("new")
    end
  end

  describe "create" do
    before do
      @user = FactoryGirl.create(:user)
      fake_login_known_user(@user)
    end

    it "should not allow a user to submit only a pseud that is not theirs" do
      @user2 = FactoryGirl.create(:user)
      work_attributes = FactoryGirl.attributes_for(:work)
      work_attributes[:author_attributes] = { ids: [@user2.pseuds.first.id] }
      expect {
        post :create, { work: work_attributes }
      }.to_not change(Work, :count)
      expect(response).to render_template("new")
      expect(flash[:error]).to eq "You're not allowed to use that pseud."
    end
  end

  describe "GET #index" do
    before do
      @fandom = FactoryGirl.create(:fandom)
      @work = FactoryGirl.create(:work, posted: true, fandom_string: @fandom.name)
    end

    it "should return the work" do
      get :index
      expect(assigns(:works)).to include(@work)
    end

    describe "without caching" do
      before do
        allow(controller).to receive(:use_caching?).and_return(false)
      end

      it "should return the result with different works the second time" do
        get :index
        expect(assigns(:works)).to include(@work)
        work2 = FactoryGirl.create(:work, posted: true)
        get :index
        expect(assigns(:works)).to include(work2)
      end
    end

    describe "with caching" do
      before do
        allow(controller).to receive(:use_caching?).and_return(true)
      end

      it "should return the same result the second time when a new work is created within the expiration time" do
        get :index
        expect(assigns(:works)).to include(@work)
        work2 = FactoryGirl.create(:work, posted: true)
        work2.index.refresh
        get :index
        expect(assigns(:works)).not_to include(work2)
      end

      describe "with an owner tag" do
        before do
          @fandom2 = FactoryGirl.create(:fandom)
          @work2 = FactoryGirl.create(:work, posted: true, fandom_string: @fandom2.name)
          @work2.index.refresh
        end

        it "should only get works under that tag" do
          get :index, tag_id: @fandom.name
          expect(assigns(:works).items).to include(@work)
          expect(assigns(:works).items).not_to include(@work2)
        end

        it "should show different results on second page" do
          get :index, tag_id: @fandom.name, page: 2
          expect(assigns(:works).items).not_to include(@work)
        end

        describe "with restricted works" do
          before do
            @work2 = FactoryGirl.create(:work, posted: true, fandom_string: @fandom.name, restricted: true)
            @work2.index.refresh
          end

          it "should not show restricted works to guests" do
            get :index, tag_id: @fandom.name
            expect(assigns(:works).items).to include(@work)
            expect(assigns(:works).items).not_to include(@work2)
          end

        end

      end
    end

  end

  describe "GET #import" do
    describe "should return the right error messages" do
      let(:user) { create(:user) }

      before do
        fake_login_known_user(user)
      end

      it "when urls are empty" do
        params = { urls: "" }
        get :import, params
        expect(flash[:error]).to eq "Did you want to enter a URL?"
      end

      it "there is an external author name but importing_for_others is NOT turned on" do
        params = { urls: "url1, url2", external_author_name: "Foo", importing_for_others: false }
        get :import, params
        expect(flash[:error]).to start_with "You have entered an external author name"
      end

      it "there is an external author email but importing_for_others is NOT turned on" do
        params = { urls: "url1, url2", external_author_email: "Foo", importing_for_others: false }
        get :import, params
        expect(flash[:error]).to start_with "You have entered an external author name"
      end

      context "the current user is NOT an archivist" do
        it "should error when importing_for_others is turned on" do
          params = { urls: "url1, url2", importing_for_others: true }
          get :import, params
          expect(flash[:error]).to start_with "You may not import stories by other users"
        end

        it "should error when importing over the maximum number of works" do
          max = ArchiveConfig.IMPORT_MAX_WORKS
          urls = Array.new(max + 1) { |i| "url#{i}" }.join(", ")
          params = { urls: urls, importing_for_others: false, import_multiple: "works" }
          get :import, params
          expect(flash[:error]).to start_with "You cannot import more than #{max}"
        end
      end

      context "the current user is an archivist" do
        it "should error when importing over the maximum number of works" do
          max = ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST
          urls = Array.new(max + 1) { |i| "url#{i}" }.join(", ")
          params = { urls: urls, importing_for_others: false, import_multiple: "works" }
          allow_any_instance_of(User).to receive(:is_archivist?).and_return(true)

          get :import, params
          expect(flash[:error]).to start_with "You cannot import more than #{max}"

          allow_any_instance_of(User).to receive(:is_archivist?).and_call_original
        end

        it "should error when importing over the maximum number of chapters" do
          max = ArchiveConfig.IMPORT_MAX_CHAPTERS
          urls = Array.new(max + 1) { |i| "url#{i}" }.join(", ")
          params = { urls: urls, importing_for_others: false, import_multiple: "chapters" }
          allow_any_instance_of(User).to receive(:is_archivist?).and_return(true)

          get :import, params
          expect(flash[:error]).to start_with "You cannot import more than #{max}"

          allow_any_instance_of(User).to receive(:is_archivist?).and_call_original
        end
      end
    end
  end
end
