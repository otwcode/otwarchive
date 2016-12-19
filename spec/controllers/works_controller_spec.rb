require 'spec_helper'

describe WorksController do
  include LoginMacros

  def it_redirects_to_user_login
    expect(response).to have_http_status(:redirect)
    expect(response).to redirect_to new_user_session_path
  end

  describe "before_filter #clean_work_search_params" do
    let(:params) { nil }

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
      let(:params) { { work_search: [] } }

      before do
        fake_login
      end

      it "returns a RecordNotFound exception" do
        controller.params = params
        controller.clean_work_search_params
        expect(controller.params[:work_search]).to be_empty
      end
    end

    context "when search parameters are provided" do
      it "should escape less and greater than in query" do

        [
          { params: "< 5 words", expected: "&lt; 5 words", message: "Should escape <" },
          { params: "> 5 words", expected: "&gt; 5 words", message: "Should escape >" },
        ].each do |settings|
          fake_login
          controller.params = { work_search: { query: settings[:params] } }
          controller.clean_work_search_params
          expect(controller.params[:work_search][:query])
            .to eq(settings[:expected]), settings[:message]
        end
      end

      it "should convert 'word' to 'word_count'" do
        controller.params = { work_search: { query: "word:5" } }
        controller.clean_work_search_params
        expect(controller.params[:work_search][:word_count]).to eq("5")
      end

      it "should convert 'words' to 'word_count'" do
        controller.params = { work_search: { query: "words:5" } }
        controller.clean_work_search_params
        expect(controller.params[:work_search][:word_count]).to eq("5")
      end

      it "should convert 'hits' queries to 'hits'"

      it "should convert other queries to (pluralized term)_count" do
        %w(kudo comment bookmark).each do |term|
          controller.params = { work_search: { query: "#{term}:5" } }
          controller.clean_work_search_params
          expect(controller.params[:work_search]["#{term.pluralize}_count"])
            .to eq("5"), "Search term '#{term}' should become #{term.pluralize}_count key"
        end
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
      work_attributes[:author_attributes] = {:ids => [@user2.pseuds.first.id]}
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


  # Method tests
  describe "check_import_errors" do
    describe "should return the right error messages" do
      before :all do
        @controller = WorksController.new
        @user = create(:user)
      end

      before :each do
        fake_login_known_user(@user)
      end

      def call_import_errors(urls, settings)
        @controller.instance_variable_set(:@urls, urls)
        @controller.instance_eval { check_import_errors(settings) }
      end

      it "when urls are empty" do
        settings = {}
        urls = []

        expect(call_import_errors(urls, settings)).to eq "Did you want to enter a URL?"
      end

      it "there is an external author name but importing_for_others is NOT turned on" do
        settings = { external_author_name: "Foo", importing_for_others: false }
        urls = %w(url1 url2)

        expect(call_import_errors(urls, settings)).to start_with "You have entered an external author name"
      end

      it "there is an external author email but importing_for_others is NOT turned on" do
        settings = { external_author_email: "Foo", importing_for_others: false }
        urls = %w(url1 url2)

        expect(call_import_errors(urls, settings)).to start_with "You have entered an external author name"
      end

      it "the current user is NOT an archivist but importing_for_others is turned on" do
        settings = { importing_for_others: true }
        urls = %w(url1 url2)

        expect(call_import_errors(urls, settings)).to start_with "You may not import stories by other users"
      end

      it "the current user is NOT an archivist and is importing over the maximum number of works" do
        max = ArchiveConfig.IMPORT_MAX_WORKS
        settings = { importing_for_others: false, import_multiple: "works" }
        urls = Array.new(max + 1) { |i| "url#{i}" }

        expect(call_import_errors(urls, settings)).to start_with "You cannot import more than #{max}"
      end

      it "the current user is an archivist and is importing over the maximum number of works" do
        max = ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST
        settings = { importing_for_others: false, import_multiple: "works" }
        urls = Array.new(max + 1) { |i| "url#{i}" }
        allow_any_instance_of(User).to receive(:is_archivist?).and_return(true)

        expect(call_import_errors(urls, settings)).to start_with "You cannot import more than #{max}"

        allow_any_instance_of(User).to receive(:is_archivist?).and_call_original
      end

    end
  end
end
