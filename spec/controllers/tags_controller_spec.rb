require 'spec_helper'

describe TagsController do
  include LoginMacros
  include RedirectExpectationHelper

  before do
    fake_login
    @current_user.roles << Role.new(name: 'tag_wrangler')
  end

  describe "wrangle" do
    context "when showing unwrangled freeforms for a fandom" do
      let(:fandom) { create(:fandom, canonical: true) }
      let(:freeform1) { create(:freeform, name: "beta") }
      let(:freeform2) { create(:freeform, name: "Omega") }
      let(:freeform3) { create(:freeform, name: "Alpha") }
      let(:freeform4) { create(:freeform, name: "an abo au") }

      before(:each) do
        create(:posted_work,
               fandom_string: fandom.name,
               freeform_string: "#{freeform1.name}, #{freeform2.name},
               #{freeform3.name}, #{freeform4.name}")
        run_all_indexing_jobs
      end

      it "includes unwrangled freeforms" do
        get :wrangle, params: { id: fandom.name, show: "freeforms", status: "unwrangled" }
        expect(assigns(:tags)).to include(freeform1)
      end

      it "sorts tags in ascending order by name" do
        get :wrangle, params: { id: fandom.name, show: "freeforms", status: "unwrangled" }
        expect(assigns(:tags).pluck(:name)).to eq([freeform3.name,
                                                   freeform4.name,
                                                   freeform1.name,
                                                   freeform2.name])
      end
    end
  
    context "when showing unwrangled relationships for a character" do
      let(:character1) { create(:character, canonical: true) }
      let(:character2) { create(:character, canonical: true) }
      let(:relationship1) { create(:relationship) }
      let(:relationship2) { create(:relationship) }

      before do
        create(:posted_work,
               character_string: character1.name,
               relationship_string: relationship1.name)
        create(:posted_work,
               character_string: character2.name,
               relationship_string: relationship2.name)
        run_all_indexing_jobs
      end

      it "includes only relationships from works with that character tag" do
        get :wrangle, params: { id: character1.name, show: "relationships", status: "unwrangled" }
        expect(assigns(:tags)).to include(relationship1)
        expect(assigns(:tags)).not_to include(relationship2)
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
      expect(put :mass_update, params: { id: @fandom1.name, show: 'freeforms', status: 'unwrangled' }).
        to redirect_to wrangle_tag_path(id: @fandom1.name,
                                        show: 'freeforms',
                                        status: 'unwrangled',
                                        page: 1,
                                        sort_column: 'name',
                                        sort_direction: 'ASC')
    end

    context "with one canonical fandom in the fandom string and a selected freeform" do
      it "should be successful" do
        put :mass_update, params: { id: @fandom1.name, show: 'freeforms', status: 'unwrangled', fandom_string: @fandom2.name, selected_tags: [@freeform1.id] }

        get :wrangle, params: { id: @fandom1.name, show: 'freeforms', status: 'unwrangled' }
        expect(assigns(:tags)).not_to include(@freeform1)

        @freeform1.reload
        expect(@freeform1.fandoms).to include(@fandom2)
      end
    end

    context "with one canonical and one noncanonical fandoms in the fandom string and a selected freeform" do
      it "should be successful" do
        put :mass_update, params: { id: @fandom1.name, show: 'freeforms', status: 'unwrangled', fandom_string: "#{@fandom2.name},#{@fandom3.name}", selected_tags: [@freeform1.id] }

        @freeform1.reload
        expect(@freeform1.fandoms).to include(@fandom2)
        expect(@freeform1.fandoms).not_to include(@fandom3)
      end
    end

    context "with two canonical fandoms in the fandom string and a selected character" do
      it "should be successful" do
        put :mass_update, params: { id: @fandom1.name, show: 'characters', status: 'unwrangled', fandom_string: "#{@fandom1.name},#{@fandom2.name}", selected_tags: [@character1.id] }

        @character1.reload
        expect(@character1.fandoms).to include(@fandom1)
        expect(@character1.fandoms).to include(@fandom2)
      end
    end

    context "with a canonical fandom in the fandom string, a selected unwrangled character, and the same character to be made canonical" do
      it "should be successful" do
        put :mass_update, params: { id: @fandom1.name, show: 'characters', status: 'unwrangled', fandom_string: "#{@fandom1.name}", selected_tags: [@character1.id], canonicals: [@character1.id] }

        @character1.reload
        expect(@character1.fandoms).to include(@fandom1)
        expect(@character1).to be_canonical
      end
    end

    context "with a canonical fandom in the fandom string, a selected synonym character, and the same character to be made canonical" do
      it "should be successful" do
        put :mass_update, params: { id: @fandom1.name, show: 'characters', status: 'unfilterable', fandom_string: "#{@fandom2.name}", selected_tags: [@character2.id], canonicals: [@character2.id] }

        @character2.reload
        expect(@character2.fandoms).to include(@fandom2)
        expect(@character2).not_to be_canonical
      end
    end

    context "A wrangler can remove associated tag" do
      it "should be successful" do
        put :mass_update, params: { id: @character3.name, remove_associated: [@character2.id] }
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
        get :reindex, params: { id: @tag.name }
        it_redirects_to_with_error(root_path, "Please log in as admin")
      end
    end
  end

  describe "feed" do
    it "You can only get a feed on Fandom, Character and Relationships" do
      @tag = FactoryGirl.create(:banned, canonical: false)
      get :feed, params: { id: @tag.id, format: :atom }
      it_redirects_to(tag_works_path(tag_id: @tag.name))
    end
  end

  describe "edit" do
    context "when editing a banned tag" do
      before do
        @tag = FactoryGirl.create(:banned)
      end

      it "redirects with an error when not an admin" do
        get :edit, params: { id: @tag.name }
        it_redirects_to_with_error(tag_wranglings_path,
                                   "Please log in as admin")
      end
    end
  end

  describe "update" do
    context "when updating a tag" do
      let(:tag) { create(:freeform) }
      let(:unsorted_tag) { create(:unsorted_tag) }

      it "resets the taggings count" do
        # manufacture a tag with borked taggings_count
        tag.taggings_count = 10
        tag.save

        put :update, params: { id: tag, tag: { fix_taggings_count: true } }
        it_redirects_to_with_notice(edit_tag_path(tag), "Tag was updated.")

        tag.reload
        expect(tag.taggings_count).to eq(0)
      end

      it "changes just the tag type" do
        put :update, params: { id: unsorted_tag, tag: { type: "Fandom" }, commit: "Save changes" }
        it_redirects_to_with_notice(edit_tag_path(unsorted_tag), "Tag was updated.")
        expect(Tag.find(unsorted_tag.id).class).to eq(Fandom)

        put :update, params: { id: unsorted_tag, tag: { type: "UnsortedTag" }, commit: "Save changes" }
        it_redirects_to_with_notice(edit_tag_path(unsorted_tag), "Tag was updated.")
        # The tag now has the original class, we can reload the original record without error.
        unsorted_tag.reload
      end
    end

    context "when updating a canonical tag" do
      let(:tag) { create(:canonical_freeform) }

      it "wrangles" do
        expect(tag.canonical?).to be_truthy
        put :update, params: { id: tag, tag: { canonical: false }, commit: "Wrangle" }
        tag.reload
        expect(tag.canonical?).to be_falsy
        it_redirects_to_with_notice(wrangle_tag_path(tag, page: 1, sort_column: "name", sort_direction: "ASC"),
                                    "Tag was updated.")
      end
    end

    context "when making a canonical tag into a synonym" do
      let(:tag) { create(:freeform, canonical: true) }
      let(:synonym) { create(:freeform, canonical: true) }

      context "when logged in as a wrangler" do
        it "errors and renders the edit page" do
          put :update, params: { id: tag, tag: { syn_string: synonym.name }, commit: "Save changes" }
          expect(response).to render_template(:edit)
          expect(assigns[:tag].errors.full_messages).to include("Only an admin can make a canonical tag into a synonym of another tag.")

          tag.reload
          expect(tag.merger_id).to eq(nil)
        end
      end

      context "when logged in as an admin" do
        it "succeeds and redirects to the edit page" do
          fake_login_admin(create(:admin))
          put :update, params: { id: tag, tag: { syn_string: synonym.name }, commit: "Save changes" }
          it_redirects_to_with_notice edit_tag_path(tag), "Tag was updated."

          tag.reload
          expect(tag.merger_id).to eq(synonym.id)
        end
      end
    end
  end
end
