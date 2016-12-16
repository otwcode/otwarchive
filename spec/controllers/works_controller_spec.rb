require 'spec_helper'

describe WorksController do
  include LoginMacros
  
  describe "new" do
    it "should not return the form for anyone not logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
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
  
  describe "index" do
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
        @user = create(:user, { id: 456 })
        @archivist = create(:user, { id: 123 })
        @archivist.roles << Role.new(name: "archivist")

        @controller = WorksController.new
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
        settings = { importing_for_others: "1" }
        urls = %w(url1 url2)
        allow(controller).to receive(:current_user) { @user }

        expect(call_import_errors(urls, settings)).to start_with "You may not import stories by other users"
      end

      it "the current user is NOT an archivist and is importing over the maximum number of works" do
        max = ArchiveConfig.IMPORT_MAX_WORKS
        settings = { importing_for_others: false, import_multiple: "works" }
        urls = Array.new(max + 1) { |i| "url#{i}" }
        allow(controller).to receive(:current_user) { @user }

        expect(call_import_errors(urls, settings)).to start_with "You cannot import more than #{max}"
      end

      it "the current user is an archivist and is importing over the maximum number of works" do
        max = ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST
        settings = { importing_for_others: 0, import_multiple: "works" }
        urls = Array.new(max + 1) { |i| "url#{i}" }
        allow(controller).to receive(:current_user) { @archivist }

        expect(call_import_errors(urls, settings)).to start_with "You cannot import more than #{max}"
      end

    end
  end
end
