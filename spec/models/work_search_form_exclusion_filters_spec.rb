require "spec_helper"

describe WorkSearchForm do
  describe "tag exclusion behavior" do
    let!(:included_work) do
      FactoryGirl.create(:work, posted: true)
    end

    let!(:excluded_work) do
      FactoryGirl.create(:work, posted: true)
    end

    describe "mergers" do

      let!(:canonical_tag) do
        FactoryGirl.create(:tag, type: "Freeform", name: "Exclude Me", canonical: true)
      end

      let!(:synonym) do
        FactoryGirl.create(:tag, type: "Freeform", name: "Excluded", canonical: false, merger: canonical_tag)
      end

      it "should exclude works with a given canonical tag name" do
        excluded_work.update(freeform_string: "Exclude Me")
        update_and_refresh_indexes("work")

        options = {
          excluded_tag_names: "Exclude Me"
        }

        search = WorkSearchForm.new(options)

        expect(search.search_results).to include(included_work)
        expect(search.search_results).not_to include(excluded_work)
      end

      it "should exclude works tagged with a synonym to a given canonical tag name" do
        excluded_work.update(freeform_string: "Excluded")
        update_and_refresh_indexes("work")

        options = {
          excluded_tag_names: "Exclude Me"
        }

        search = WorkSearchForm.new(options)

        expect(search.search_results).to include(included_work)
        expect(search.search_results).not_to include(excluded_work)
      end

      it "should exclude works tagged with a canonical tag given that tag's synonym" do
        excluded_work.update(freeform_string: "Exclude Me")
        update_and_refresh_indexes("work")

        options = {
          excluded_tag_names: "Excluded"
        }

        search = WorkSearchForm.new(options)

        expect(search.search_results).to include(included_work)
        expect(search.search_results).not_to include(excluded_work)
      end
    end

    describe "meta tagging" do
      let!(:grand_parent_tag) do
        FactoryGirl.create(:tag, type: "Character", name: "Sam")
      end

      let!(:parent_tag) do
        FactoryGirl.create(:tag, type: "Character", name: "Sam Winchester")
      end

      let!(:child_tag) do
        FactoryGirl.create(:tag, type: "Character", name: "Endverse Sam Winchester")
      end

      let!(:grand_parent_parent_meta_tagging) do
        FactoryGirl.create(
          :meta_tagging,
          meta_tag_id: grand_parent_tag.id,
          sub_tag_id: parent_tag.id,
          direct: true
        )
      end

      let!(:grand_parent_child_meta_tagging) do
        FactoryGirl.create(
          :meta_tagging,
          meta_tag_id: grand_parent_tag.id,
          sub_tag_id: child_tag.id,
          direct: false
        )
      end

      let!(:parent_child_meta_tagging) do
        FactoryGirl.create(
          :meta_tagging,
          meta_tag_id: parent_tag.id,
          sub_tag_id: child_tag.id,
          direct: true
        )
      end

      it "should exclude works tagged with direct sub tags of the given superset tag name" do
        excluded_work.update(character_string: "Sam Winchester")
        update_and_refresh_indexes("work")

        options = {
          excluded_tag_names: "Sam"
        }

        search = WorkSearchForm.new(options)

        expect(search.search_results).to include(included_work)
        expect(search.search_results).not_to include(excluded_work)
      end

      it "should not exclude works tagged with the direct superset of the given sub tag name" do
        included_work.update(character_string: "Sam")
        excluded_work.update(character_string: "Sam Winchester")
        update_and_refresh_indexes("work")

        options = {
          excluded_tag_names: "Sam Winchester"
        }

        search = WorkSearchForm.new(options)

        expect(search.search_results).to include(included_work)
        expect(search.search_results).not_to include(excluded_work)
      end

      it "should exclude works tagged with indirect sub tags of the given superset tag name" do
        excluded_work.update(character_string: "Endverse Sam Winchester")
        update_and_refresh_indexes("work")

        options = {
          excluded_tag_names: "Sam"
        }

        search = WorkSearchForm.new(options)

        expect(search.search_results).to include(included_work)
        expect(search.search_results).not_to include(excluded_work)
      end

      it "should not exclude works tagged with the indirect superset of the given sub tag name" do
        included_work.update(character_string: "Sam")
        excluded_work.update(character_string: "Endverse Sam Winchester")
        update_and_refresh_indexes("work")

        options = {
          excluded_tag_names: "Endverse Sam Winchester"
        }

        search = WorkSearchForm.new(options)

        expect(search.search_results).to include(included_work)
        expect(search.search_results).not_to include(excluded_work)
      end
    end

    describe "common tagging" do
      let!(:fandom_tag) do
        FactoryGirl.create(:tag, type: "Fandom", name: "Dr. Horrible's Sing-Along Blog", canonical: true)
      end

      let!(:character_tag) do
        FactoryGirl.create(:tag, type: "Character", name: "Penny", canonical: true)
      end

      let!(:relationship_tag) do
        FactoryGirl.create(:tag, type: "Relationship", name: "Billy/Penny", canonical: true)
      end

      let!(:common_tagging_fandom) do
        FactoryGirl.create(:common_tagging, filterable: fandom_tag, common_tag: character_tag)
      end

      let!(:common_tagging_character) do
        FactoryGirl.create(:common_tagging, filterable: character_tag, common_tag: relationship_tag)
      end

      let!(:third_work) do
        FactoryGirl.create(:work, posted: true)
      end

      it "should not exclude character works when given a fandom parent" do
        third_work.update(character_string: "Penny", relationship_string: "Billy/Penny")
        update_and_refresh_indexes("work")

        options = {
          excluded_tag_names: "Dr. Horrible's Sing-Along Blog"
        }

        search = WorkSearchForm.new(options)

        expect(search.search_results).to include(included_work)
        expect(search.search_results).to include(third_work)
      end

      it "should exclude relationship but not fandom works hen given a character tag" do
        included_work.update(fandom_string: "Dr. Horrible's Sing-Along Blog")
        excluded_work.update(character_string: "Penny")
        third_work.update(relationship_string: "Billy/Penny")
        update_and_refresh_indexes("work")

        options = {
          excluded_tag_names: "Penny"
        }

        search = WorkSearchForm.new(options)

        expect(search.search_results).to include(included_work)
        expect(search.search_results).not_to include(excluded_work)
        expect(search.search_results).not_to include(third_work)
      end
    end

  end
end
