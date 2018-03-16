require "spec_helper"

describe BookmarkSearchForm do
  describe "tag exclusion behavior" do
    let!(:user) do
      FactoryGirl.create(:user)
    end

    let!(:included_work) do
      FactoryGirl.create(:work, posted: true)
    end

    let!(:excluded_work) do
      FactoryGirl.create(:work, posted: true)
    end

    let!(:included_bookmark) do
      FactoryGirl.create(
        :bookmark,
        bookmarkable_id: included_work.id,
        pseud_id: user.default_pseud.id
      )
    end

    let!(:excluded_bookmark) do
      FactoryGirl.create(
        :bookmark,
        bookmarkable_id: excluded_work.id,
        pseud_id: user.default_pseud.id
      )
    end

    describe "mergers" do
      let!(:canonical_work_tag) do
        FactoryGirl.create(:tag, type: "Freeform", name: "Exclude Work Tag", canonical: true)
      end

      let!(:work_tag_synonym) do
        FactoryGirl.create(:tag, type: "Freeform", name: "Tagged Work Exclusion", canonical: false, merger: canonical_work_tag)
      end

      let!(:canonical_bookmark_tag) do
        FactoryGirl.create(:tag, type: "Freeform", name: "Complete", canonical: true)
      end

      let!(:bookmark_tag_synonym) do
        FactoryGirl.create(:tag, type: "Freeform", name: "i finished it", canonical: false, merger: canonical_bookmark_tag)
      end

      it "should exclude bookmarks for works with a given canonical tag name" do
        excluded_work.update(freeform_string: "Exclude Work Tag")
        update_and_refresh_indexes("bookmark")

        options = {
          excluded_tag_names: "Exclude Work Tag"
        }

        search = BookmarkSearchForm.new(options)

        expect(search.search_results).to include(included_bookmark)
        expect(search.search_results).not_to include(excluded_bookmark)
      end

      it "should exclude bookmarks tagged with a given canonical tag name" do
        excluded_bookmark.update(tag_string: "Complete")
        update_and_refresh_indexes("bookmark")

        options = {
          excluded_bookmark_tag_names: "Complete"
        }

        search = BookmarkSearchForm.new(options)

        expect(search.search_results).to include(included_bookmark)
        expect(search.search_results).not_to include(excluded_bookmark)
      end

      it "should exclude bookmarks for works tagged with a synonym to a given canonical tag name" do
        excluded_work.update(freeform_string: "Tagged Work Exclusion")
        update_and_refresh_indexes("bookmark")

        options = {
          excluded_tag_names: "Exclude Work Tag"
        }

        search = BookmarkSearchForm.new(options)

        expect(search.search_results).to include(included_bookmark)
        expect(search.search_results).not_to include(excluded_bookmark)
      end

      # it "should exclude bookmarks tagged with a synonym to a given canonical tag name" do
      #   excluded_bookmark.update(tag_string: "i finished it")
      #   update_and_refresh_indexes("bookmark")

      #   options = {
      #     excluded_tag_names: "Complete"
      #   }

      #   search = BookmarkSearchForm.new(options)

      #   expect(search.search_results).to include(included_bookmark)
      #   expect(search.search_results).not_to include(excluded_bookmark)
      # end

      it "should exclude bookmarks for works tagged with a canonical tag given that tag's synonym" do
        excluded_work.update(freeform_string: "Exclude Work Tag")
        update_and_refresh_indexes("bookmark")

        options = {
          excluded_tag_names: "Tagged Work Exclusion"
        }

        search = BookmarkSearchForm.new(options)

        expect(search.search_results).to include(included_bookmark)
        expect(search.search_results).not_to include(excluded_bookmark)
      end

      # it "should exclude bookmarks tagged with a canonical tag given that tag's synonym" do
      #   excluded_bookmark.update(tag_string: "Complete")
      #   update_and_refresh_indexes("bookmark")

      #   options = {
      #     excluded_bookmark_tag_names: "i finished it"
      #   }

      #   search = BookmarkSearchForm.new(options)

      #   expect(search.search_results).to include(included_bookmark)
      #   expect(search.search_results).not_to include(excluded_bookmark)
      # end
    end

    # describe "meta tagging" do
    #   let!(:grand_parent_tag) do
    #     FactoryGirl.create(:freeform, name: "Weird")
    #   end

    #   let!(:parent_tag) do
    #     FactoryGirl.create(:freeform, name: "Weird (but still good!)")
    #   end

    #   let!(:child_tag) do
    #     FactoryGirl.create(:freeform, name: "Weird (but still good!) (but still weird)")
    #   end

    #   before(:each) do
    #     child_tag.update(meta_tag_string: parent_tag.name)
    #     parent_tag.update(meta_tag_string: grand_parent_tag.name)
    #   end

      # it "should exclude bookmarks tagged with direct sub tags of the given superset tag name" do
      #   excluded_bookmark.update(tag_string: "Weird (but still good!)")
      #   update_and_refresh_indexes("bookmark")

      #   options = {
      #     excluded_tag_names: "Weird"
      #   }

      #   search = BookmarkSearchForm.new(options)

      #   expect(search.search_results).to include(included_bookmark)
      #   expect(search.search_results).not_to include(excluded_bookmark)
      # end

      # it "should not exclude bookmarks tagged with the direct superset of the given sub tag name" do
      #   included_bookmark.update(tag_string: "Weird")
      #   excluded_bookmark.update(tag_string: "Weird (but still good!)")
      #   update_and_refresh_indexes("bookmark")

      #   options = {
      #     excluded_tag_names: "Weird (but still good!)"
      #   }

      #   search = BookmarkSearchForm.new(options)

      #   expect(search.search_results).to include(included_bookmark)
      #   expect(search.search_results).not_to include(excluded_bookmark)
      # end

    #   it "should exclude bookmarks tagged with indirect sub tags of the given superset tag name" do
    #     excluded_bookmark.update(tag_string: "Weird (but still good!) (but still weird)")
    #     update_and_refresh_indexes("bookmark")

    #     options = {
    #       excluded_tag_names: "Weird"
    #     }

    #     search = BookmarkSearchForm.new(options)

    #     expect(search.search_results).to include(included_bookmark)
    #     expect(search.search_results).not_to include(excluded_bookmark)
    #   end

    #   it "should not exclude works tagged with the indirect superset of the given sub tag name" do
    #     included_bookmark.update(tag_string: "Weird")
    #     excluded_bookmark.update(tag_string: "Weird (but still good!) (but still weird)")
    #     update_and_refresh_indexes("bookmark")

    #     options = {
    #       excluded_tag_names: "Weird (but still good!) (but still weird)"
    #     }

    #     search = BookmarkSearchForm.new(options)

    #     expect(search.search_results).to include(included_bookmark)
    #     expect(search.search_results).not_to include(excluded_bookmark)
    #   end
    # end

    # describe "common tagging" do
    #   let!(:filterable_tag) do
    #     FactoryGirl.create(:tag, type: "Fandom", name: "Battlestar Galactica", canonical: true)
    #   end

    #   let!(:common_tag) do
    #     FactoryGirl.create(:tag, type: "Character", name: "Laura Roslin", canonical: true)
    #   end

    #   before(:each) do
    #     common_tag.update(parents: [filterable_tag])
    #   end

    #   it "should exclude bookmarks for works with common tags when given that common tag's parent" do
    #     excluded_work.update(character_string: "Laura Roslin")
    #     update_and_refresh_indexes("bookmark")

    #     options = {
    #       excluded_tag_names: "Battlestar Galactica"
    #     }

    #     search = BookmarkSearchForm.new(options)

    #     expect(search.search_results).to include(included_bookmark)
    #     expect(search.search_results).not_to include(excluded_bookmark)
    #   end

    #   it "should not exclude bookmarks for works with tags when given that tag's child" do
    #     included_work.update(fandom_string: "Battlestar Galactica")
    #     excluded_work.update(character_string: "Laura Roslin")
    #     update_and_refresh_indexes("bookmark")

    #     options = {
    #       excluded_tag_names: "Laura Roslin"
    #     }

    #     search = BookmarkSearchForm.new(options)

    #     expect(search.search_results).to include(included_bookmark)
    #     expect(search.search_results).not_to include(excluded_bookmark)
    #   end
    # end

  end
end
