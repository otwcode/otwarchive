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

        expect(assigns(:tags)).to include(@freeform1)
      end
    end
  end

  describe "mass_update" do
    before do
      @fandom1 = FactoryGirl.create(:fandom, canonical: true)
      @fandom2 = FactoryGirl.create(:fandom, canonical: true)
      @fandom3 = FactoryGirl.create(:fandom, canonical: false)

      @freeform1 = FactoryGirl.create(:freeform, canonical: false)
      @character1 = FactoryGirl.create(:character, canonical: false)
      @character2 = FactoryGirl.create(:character, canonical: false, merger: FactoryGirl.create(:character, canonical: true))
      @work = FactoryGirl.create(:work, posted: true, fandom_string: "#{@fandom1.name}", character_string: "#{@character1.name},#{@character2.name}", freeform_string: "#{@freeform1.name}")
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
        expect(assigns(:tags)).not_to include(@freeform1)

        @freeform1.reload
        expect(@freeform1.fandoms).to include(@fandom2)
      end
    end

    context "with one canonical and one noncanonical fandoms in the fandom string and a selected freeform" do
      it "should be successful" do
        put :mass_update, id: @fandom1.name, show: 'freeforms', status: 'unwrangled', fandom_string: "#{@fandom2.name},#{@fandom3.name}", selected_tags: [@freeform1.id]

        @freeform1.reload
        expect(@freeform1.fandoms).to include(@fandom2)
        expect(@freeform1.fandoms).not_to include(@fandom3)
      end
    end

    context "with two canonical fandoms in the fandom string and a selected character" do
      it "should be successful" do
        put :mass_update, id: @fandom1.name, show: 'characters', status: 'unwrangled', fandom_string: "#{@fandom1.name},#{@fandom2.name}", selected_tags: [@character1.id]

        @character1.reload
        expect(@character1.fandoms).to include(@fandom1)
        expect(@character1.fandoms).to include(@fandom2)
      end
    end

    context "with a canonical fandom in the fandom string, a selected unwrangled character, and the same character to be made canonical" do
      it "should be successful" do
        put :mass_update, id: @fandom1.name, show: 'characters', status: 'unwrangled', fandom_string: "#{@fandom1.name}", selected_tags: [@character1.id], canonicals: [@character1.id]

        @character1.reload
        expect(@character1.fandoms).to include(@fandom1)
        expect(@character1).to be_canonical
      end
    end

    context "with a canonical fandom in the fandom string, a selected synonym character, and the same character to be made canonical" do
      it "should be successful" do
        put :mass_update, id: @fandom1.name, show: 'characters', status: 'unfilterable', fandom_string: "#{@fandom2.name}", selected_tags: [@character2.id], canonicals: [@character2.id]

        @character2.reload
        expect(@character2.fandoms).to include(@fandom2)
        expect(@character2).not_to be_canonical
      end
    end
  end

  describe "update" do
    context "when fixing a tag's taggings_count" do
      before do
        @tag = FactoryGirl.create(:freeform)
        # manufacture a tag with borked taggings_count
        @tag.taggings_count = 10
        @tag.save
      end

      it "should reset the taggings_count" do
        put :update, id: @tag.name, tag: { fix_taggings_count: true }

        @tag.reload
        expect(@tag.taggings_count).to eq(0)
      end
    end
  end
end
