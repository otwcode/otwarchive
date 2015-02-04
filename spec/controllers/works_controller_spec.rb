require 'spec_helper'

describe WorksController do
  include LoginMacros

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

        xit "should only get works under that tag" do
          get :index, tag_id: @fandom.name
          expect(assigns(:works).items).to include(@work)
          expect(assigns(:works).items).not_to include(@work2)
        end

        xit "should show different results on second page" do
          get :index, tag_id: @fandom.name, page: 2
          expect(assigns(:works).items).not_to include(@work)
        end

        describe "with restricted works" do
          before do
            @work2 = FactoryGirl.create(:work, posted: true, fandom_string: @fandom.name, restricted: true)
            @work2.index.refresh
          end

          xit "should not show restricted works to guests" do
            get :index, tag_id: @fandom.name
            expect(assigns(:works).items).to include(@work)
            expect(assigns(:works).items).not_to include(@work2)
          end

          xit "should show restricted works to logged-in users" do
            fake_login
            get :index, tag_id: @fandom.name
            expect(assigns(:works).items).to match_array([@work, @work2])
          end
        end

      end
    end

  end

end
