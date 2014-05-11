require 'spec_helper'

describe TagsController do
  include LoginMacros

  before do
    fake_login            
    @current_user.roles << Role.new(name: 'tag_wrangler')
  end

  describe "wrangle" do
    context "a fandom's unwrangled freeforms page" do
      before do
        @fandom = FactoryGirl.create(:fandom, canonical: true)
        @freeform1 = FactoryGirl.create(:freeform)
        @work = FactoryGirl.create(:work, posted: true, fandom_string: "#{@fandom.name}", freeform_string: "#{@freeform1.name}")
      end

      it "should show those freeforms" do
        get :wrangle, id: @fandom.name, show: 'freeforms', status: 'unwrangled'

        assigns(:tags).should include(@freeform1)
      end
    end
  end

  describe "mass_update" do
    before do
      @fandom1 = FactoryGirl.create(:fandom, canonical: true)
      @fandom2 = FactoryGirl.create(:fandom, canonical: true)
      @fandom3 = FactoryGirl.create(:fandom, canonical: false)

      @freeform1 = FactoryGirl.create(:freeform, canonical: false)
      @work = FactoryGirl.create(:work, posted: true, fandom_string: "#{@fandom1.name}", freeform_string: "#{@freeform1.name}")
    end

    xit "should redirect to the wrangle action for that tag" do
      expect {
        put :mass_update, id: @fandom1.name, show: 'freeforms', status: 'unwrangled'
      }.to redirect_to wrangle_tag_path(id: @fandom1.name, show: 'freeforms', status: 'unwrangled')
    end

    context "with one canonical fandom in the fandom string and a selected freeform" do
      it "should be successful" do
        put :mass_update, id: @fandom1.name, show: 'freeforms', status: 'unwrangled', fandom_string: @fandom2.name, selected_tags: [@freeform1.id]

        get :wrangle, id: @fandom1.name, show: 'freeforms', status: 'unwrangled'
        assigns(:tags).should_not include(@freeform1)

        @freeform1.reload
        @freeform1.fandoms.should include(@fandom2)
      end
    end

    context "with one canonical and one noncanonical fandoms in the fandom string and a selected freeform" do
      it "should be successful" do
        put :mass_update, id: @fandom1.name, show: 'freeforms', status: 'unwrangled', fandom_string: "#{@fandom2.name},#{@fandom3.name}", selected_tags: [@freeform1.id]

        @freeform1.reload
        @freeform1.fandoms.should include(@fandom2)
        @freeform1.fandoms.should_not include(@fandom3)
      end
    end
  end
end
