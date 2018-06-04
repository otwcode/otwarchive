require 'spec_helper'

describe TagsController do
  include LoginMacros
  include RedirectExpectationHelper

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
        get :wrangle, params: { id: @fandom.name, show: 'freeforms', status: 'unwrangled' }

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
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq "Please log in as admin"
      end
    end
  end

  describe "feed" do
    it "You can only get a feed on Fandom, Character and Relationships" do
      @tag = FactoryGirl.create(:banned, canonical: false)
      get :feed, params: { id: @tag.id, format: :atom }
      expect(response).to redirect_to(tag_works_path(tag_id: @tag.name))
    end
  end

  describe "edit" do
    context "when editing a tag" do
      before do
        @tag = FactoryGirl.create(:banned)
      end

      it "Only an admin can edit a banned tag" do
        get :edit, params: { id: @tag.name }
        expect(flash[:error]).to eq "Please log in as admin"
        expect(response).to redirect_to(tag_wranglings_path)
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
        it_redirects_to_with_notice edit_tag_path(tag), "Tag was updated."

        tag.reload
        expect(tag.taggings_count).to eq(0)
      end

      it "changes just the tag type" do
        put :update, params: { id: unsorted_tag, tag: { type: "Fandom" }, commit: "Save changes" }
        it_redirects_to_with_notice edit_tag_path(unsorted_tag), "Tag was updated."
        expect(Tag.find(unsorted_tag.id).class).to eq(Fandom)

        put :update, params: { id: unsorted_tag, tag: { type: "UnsortedTag" }, commit: "Save changes" }
        it_redirects_to_with_notice edit_tag_path(unsorted_tag), "Tag was updated."
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
        it_redirects_to wrangle_tag_path(tag, page: 1, sort_column: "name", sort_direction: "ASC")
      end
    end

    shared_examples "success message" do
      it "should show a success message" do
        expect(flash[:notice]).to eq("Tag was updated.")
      end
    end

    describe "adding a new associated tag" do
      render_views # make sure we can view the error messages

      let(:tag) { create(:character, canonical: true) }
      let(:associated) { nil } # to be overridden by the examples
      let(:field) { "#{associated.type.downcase}_string" }

      before do
        put :update, params: {
          id: tag.name, tag: { "#{field}": associated.name }
        }

        tag.reload
      end

      shared_examples "invalid association" do
        it "should not add the associated tag" do
          expect(tag.parents).not_to include(associated)
          expect(tag.children).not_to include(associated)
        end
      end

      context "when the associated tag doesn't exist" do
        let(:associated) do
          destroyed_fandom = create(:fandom)
          destroyed_fandom.destroy
          destroyed_fandom
        end

        it "should show an error" do
          expect(response.body).to include(
            "Cannot add association to '#{associated.name}': " \
            "Common tag does not exist."
          )
        end

        include_examples "invalid association"
      end

      context "when the associated tag is entered into the wrong field" do
        let(:associated) { create(:fandom, canonical: true) }
        let(:field) { "relationship_string" }

        it "should show an error" do
          expect(response.body).to include(
            "Cannot add association to '#{associated.name}': " \
            "#{associated.type} added in Relationship field."
          )
        end

        include_examples "invalid association"
      end

      context "when the associated tag has an invalid type" do
        # NOTE This will enter the associated tag into the freeform_string
        # field, which is not displayed on the form. This still might come up
        # in the extremely rare case where a tag wrangler loads the form, a
        # different tag wrangler goes in and changes the type of the tag being
        # edited, and then the first wrangler submits the form.
        let(:associated) { create(:freeform, canonical: true) }

        it "should show an error" do
          expect(response.body).to include(
            "Cannot add association to '#{associated.name}': A tag of type " \
            "#{tag.type} cannot have a child of type #{associated.type}."
          )
        end

        include_examples "invalid association"
      end

      context "when the associated tag has a valid type" do
        context "when the tag is a canonical child" do
          let(:associated) { create(:relationship, canonical: true) }

          include_examples "success message"

          it "should add the association" do
            expect(tag.parents).not_to include(associated)
            expect(tag.children).to include(associated)
          end
        end

        context "when the tag is a non-canonical child" do
          let(:associated) { create(:relationship, canonical: false) }

          include_examples "success message"

          it "should add the association" do
            expect(tag.parents).not_to include(associated)
            expect(tag.children).to include(associated)
          end
        end

        context "when the tag is a canonical parent" do
          let(:associated) { create(:fandom, canonical: true) }

          include_examples "success message"

          it "should add the association" do
            expect(tag.parents).to include(associated)
            expect(tag.children).not_to include(associated)
          end
        end

        context "when the tag is a non-canonical parent" do
          let(:associated) { create(:fandom, canonical: false) }

          it "should show an error" do
            expect(response.body).to include(
              "Cannot add association to '#{associated.name}': " \
              "Parent tag is not canonical."
            )
          end

          include_examples "invalid association"
        end
      end
    end

    describe "adding a new metatag" do
      render_views # make sure we can view the error messages

      let(:tag) { create(:freeform, canonical: true) }
      let(:meta) { nil } # to be overridden by the examples

      before do
        put :update, params: {
          id: tag.name, tag: { meta_tag_string: meta.name }
        }

        tag.reload
      end

      shared_examples "invalid meta tag" do
        it "should not add the meta tag" do
          expect(tag.meta_tags).not_to include(meta)
        end
      end

      context "when the tag is not canonical" do
        let(:meta) { create(:freeform, canonical: false) }

        it "should show an error" do
          expect(response.body).to include(
            "Invalid meta tag '#{meta.name}': " \
            "Meta taggings can only exist between canonical tags."
          )
        end

        include_examples "invalid meta tag"
      end

      context "when the tag is the wrong type" do
        let(:meta) { create(:character, canonical: true) }

        it "should show an error" do
          expect(response.body).to include(
            "Invalid meta tag '#{meta.name}': " \
            "Meta taggings can only exist between two tags of the same type."
          )
        end

        include_examples "invalid meta tag"
      end

      context "when the metatag is itself" do
        let(:meta) { tag }

        it "should show an error" do
          expect(response.body).to include(
            "Invalid meta tag '#{meta.name}': " \
            "A tag can't be its own meta tag."
          )
        end

        include_examples "invalid meta tag"
      end

      context "when the metatag is its subtag" do
        let(:meta) do
          sub = create(:freeform, canonical: true)
          MetaTagging.create(meta_tag: tag, sub_tag: sub, direct: true)
          tag.reload
          sub.reload
        end

        it "should show an error" do
          expect(response.body).to include(
            "Invalid meta tag '#{meta.name}': " \
            "A meta tag can't be its own grandpa."
          )
        end

        include_examples "invalid meta tag"
      end

      context "when the metatag is already its grandparent" do
        let(:meta) do
          parent = create(:freeform, canonical: true)
          grandparent = create(:freeform, canonical: true)

          parent.sub_tags << tag
          parent.meta_tags << grandparent

          # We want to add the grandparent as our new metatag.
          grandparent
        end

        it "should show an error" do
          expect(response.body).to include(
            "Invalid meta tag '#{meta.name}': Meta tag has already been " \
            "added (possibly as an indirect meta tag)."
          )
        end

        it "should not create two meta-taggings" do
          expect(MetaTagging.where(sub_tag: tag, meta_tag: meta).count).to eq 1
        end
      end
    end
  end
end
