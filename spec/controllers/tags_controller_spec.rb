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
      @character3 = FactoryGirl.create(:character, canonical: false)
      @character2 = FactoryGirl.create(:character, canonical: false, merger: @character3)
      @work = FactoryGirl.create(:work,
                                 posted: true,
                                 fandom_string: "#{@fandom1.name}",
                                 character_string: "#{@character1.name},#{@character2.name}",
                                 freeform_string: "#{@freeform1.name}")
    end

    it "should redirect to the wrangle action for that tag" do
      expect(put :mass_update, id: @fandom1.name, show: 'freeforms', status: 'unwrangled').
        to redirect_to wrangle_tag_path(id: @fandom1.name,
                                        show: 'freeforms',
                                        status: 'unwrangled',
                                        page: 1,
                                        sort_column: 'name',
                                        sort_direction: 'ASC')
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

    context "A wrangler can remove associated tag" do
      it "should be successful" do
        put :mass_update, id: @character3.name, remove_associated: [@character2.id]
        expect(flash[:notice]).to eq "The following tags were successfully removed: #{@character2.name}"
        expect(flash[:error]).to be_nil
        expect(@character3.mergers).to eq []
      end
    end
  end

  describe "reindex" do
    context "when reindexing a tag" do
      before do
        @tag = FactoryGirl.create(:freeform)
      end

      it "Only an admin can reindex a tag" do
        get :reindex, id: @tag.name        
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq "Please log in as admin"
      end
    end
  end

  describe "feed" do
    it "You can only get a feed on Fandom, Character and Relationships" do
      @tag = FactoryGirl.create(:banned, canonical: false)
      get :feed, id: @tag.id, format: :atom
      expect(response).to redirect_to(tag_works_path(tag_id: @tag.name))
    end
  end

  describe "edit" do
    context "when editing a tag" do
      before do
        @tag = FactoryGirl.create(:banned)
      end

      it "Only an admin can edit a banned tag" do
        get :edit, id: @tag.name
        expect(flash[:error]).to eq "Please log in as admin"
        expect(response).to redirect_to(tag_wranglings_path)
      end
    end
  end

  describe "update" do
    context "when updating a tag" do
      before do
        @tag = FactoryGirl.create(:freeform)
      end

      it "should reset the taggings_count" do
        # manufacture a tag with borked taggings_count
        @tag.taggings_count = 10
        @tag.save
        put :update, id: @tag.name, tag: { fix_taggings_count: true }
        @tag.reload
        expect(@tag.taggings_count).to eq(0)
      end

      it "you can wrangle" do
        put :update, id: @tag.name, tag: {}, commit: :Wrangle
        expect(response).to redirect_to(tag_path(@tag) + "/wrangle?page=1&sort_column=name&sort_direction=ASC")
      end
    end
  end
end
