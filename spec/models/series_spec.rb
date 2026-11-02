# frozen_string_literal: true

require "spec_helper"

describe Series do
  let(:unrestricted_character) { create(:canonical_character) }
  let(:restricted_character) { create(:canonical_character) }
  let(:unrestricted_work) { create(:work, restricted: false, character_string: unrestricted_character.name, freeform_string: "MyFreeform") }
  let(:restricted_work) { create(:work, restricted: true, character_string: restricted_character.name, freeform_string: "MyFreeform2") }
  let(:series) { create(:series) }

  describe "#restricted" do
    context "when the series has only unrestricted works" do
      before do
        series.works = [unrestricted_work]
        series.reload
      end

      it "returns false" do
        expect(series.restricted).to be_falsy
      end
    end

    context "when the series only has restricted works" do
      before do
        series.works = [restricted_work]
        series.reload
      end

      it "returns true" do
        expect(series.restricted).to be_truthy
      end
    end

    context "when the series has both restricted and unrestricted works" do
      before do
        series.works = [restricted_work, unrestricted_work]
        series.reload
      end

      it "returns false" do
        expect(series.restricted).to be_falsy
      end
    end
  end

  it "has all of the pseuds from all of its serial works" do
    series.works = [restricted_work, unrestricted_work]
    series.reload
    expect(series.work_pseuds).to match_array(unrestricted_work.pseuds +
                                              restricted_work.pseuds)
    expect(series.pseuds).to include(*unrestricted_work.pseuds.to_a)
    expect(series.pseuds).to include(*restricted_work.pseuds.to_a)
  end

  describe "#visible_word_count" do
    let(:hidden_work) { create(:work, hidden_by_admin: true) }

    context "when not logged in" do
      it "counts public work words" do
        series.works = [unrestricted_work]
        series.reload
        expect(series.visible_word_count).to eq(unrestricted_work.word_count)
      end

      it "excludes restricted work words" do
        series.works = [unrestricted_work, restricted_work]
        series.reload
        expect(series.visible_word_count).to eq(unrestricted_work.word_count)
      end

      it "excludes hidden-by-admin work words" do
        series.works = [unrestricted_work, hidden_work]
        series.reload
        expect(series.visible_word_count).to eq(unrestricted_work.word_count)
      end
    end

    context "when logged in" do
      let(:creator) { create(:user) }
      # We get co-creator warnings when creating the series unless we re-create these
      # works with the logged-in user (co-creator warnings are tested elsewhere)
      let(:unrestricted_work) { create(:work, restricted: false, authors: [creator.default_pseud]) }
      let(:restricted_work) { create(:work, restricted: false, authors: [creator.default_pseud]) }
      let(:hidden_work) { create(:work, hidden_by_admin: true, authors: [creator.default_pseud]) }

      before do
        User.current_user = creator
      end

      it "counts public work words" do
        series = create(:series, works: [unrestricted_work], authors: [creator.default_pseud])
        expect(series.visible_word_count).to eq(unrestricted_work.word_count)
      end

      it "includes restricted work words too" do
        series = create(:series, works: [unrestricted_work, restricted_work], authors: [creator.default_pseud])
        expect(series.visible_word_count).to eq(unrestricted_work.word_count + restricted_work.word_count)
      end

      it "excludes hidden-by-admin work words" do
        series = create(:series, works: [unrestricted_work, hidden_work], authors: [creator.default_pseud])
        expect(series.visible_word_count).to eq(unrestricted_work.word_count)
      end
    end
  end

  describe "co-creator permissions" do
    let(:creator) { create(:user) }
    let(:co_creator) { create(:user) }
    let(:no_co_creator) { create(:user) }

    before do
      # In order to enable co-creator checks (instead of just having everything
      # be automatically approved), we need to make sure that User.current_user
      # is not nil.
      User.current_user = creator
      co_creator.preference.update!(allow_cocreator: true)
      no_co_creator.preference.update!(allow_cocreator: false)
    end

    it "allows normal users to invite others as series co-creators" do
      work = create(:work, authors: creator.pseuds)
      series = create(:series, authors: creator.pseuds, works: [work])
      series.author_attributes = { byline: co_creator.login }
      expect(series).to be_valid
      expect(series.save).to be_truthy
      expect(series.user_has_creator_invite?(co_creator)).to be_truthy
    end

    it "doesn't allow users to invite others who disallow co-creators" do
      work = create(:work, authors: creator.pseuds)
      series = create(:series, authors: creator.pseuds, works: [work])
      series.author_attributes = { byline: no_co_creator.login }
      expect(series).to be_invalid
      expect(series.save).to be_falsey
      expect(series.user_has_creator_invite?(no_co_creator)).to be_falsey
    end

    it "allows new series to be added to an existing work co-created with someone who disallowed co-creators" do
      # Set up a work co-created with a user that doesn't allow co-creators:
      no_co_creator.preference.update!(allow_cocreator: true)
      work = create(:work, authors: creator.pseuds + no_co_creator.pseuds)
      work.creatorships.for_user(no_co_creator).each(&:accept!)
      no_co_creator.preference.update!(allow_cocreator: false)

      series = create(:series, authors: creator.pseuds)
      work.reload.series << series
      expect(series.pseuds.reload).to match_array(creator.pseuds +
                                                  no_co_creator.pseuds)
    end
  end

  describe "#general_filters" do
    it "includes tags on unrestricted works" do
      series.works = [unrestricted_work]
      series.reload
      expect(series.general_filters).to include(*unrestricted_work.tags.canonical)
    end

    it "includes tags on restricted works" do
      series.works = [restricted_work]
      series.reload
      expect(series.general_filters).to include(*restricted_work.tags.canonical)
    end

    it "does not include tags on works hidden by an admin" do
      hidden_work = create(:work, hidden_by_admin: true, character_string: create(:canonical_character).name)
      series.works = [hidden_work]
      series.reload
      expect(series.general_filters).to be_empty
    end
  end

  describe "#public_filters" do
    it "includes tags on unrestricted works" do
      series.works = [unrestricted_work]
      series.reload
      expect(series.public_filters).to include(*unrestricted_work.tags.canonical)
    end

    it "does not include tags on restricted works" do
      series.works = [restricted_work]
      series.reload
      expect(series.public_filters).to be_empty
    end

    it "does not include tags on works hidden by an admin" do
      hidden_work = create(:work, hidden_by_admin: true, character_string: create(:canonical_character).name)
      series.works = [hidden_work]
      series.reload
      expect(series.public_filters).to be_empty
    end
  end

  describe "#remove_author" do
    context "when a work in the series has a chapter whose sole creator is being removed" do
      let(:to_remove) { create(:user, login: "to_remove") }
      let(:other) { create(:user, login: "other") }

      let!(:work) do
        create(:work, authors: [to_remove.default_pseud, other.default_pseud])
      end

      let!(:solo_chapter) do
        create(:chapter, work: work, authors: [to_remove.default_pseud])
      end

      let!(:series) do
        create(:series,
               works: [work],
               authors: [to_remove.default_pseud, other.default_pseud])
      end

      # Make sure we see the newest chapter:
      before { series.reload }

      it "sets the chapter's and the work's creators" do
        series.remove_author(to_remove)
        expect(series.pseuds.reload).to contain_exactly(other.default_pseud)
        expect(work.pseuds.reload).to contain_exactly(other.default_pseud)
        expect(solo_chapter.pseuds.reload).to contain_exactly(other.default_pseud)
      end
    end
  end

  describe "#fandoms" do
    let(:restricted_work) { create(:work, restricted: true, fandom_string: "Testing2") }
    let(:hidden_work) { create(:work, hidden_by_admin: true, fandom_string: "Testing3") }
    let(:draft_work) { create(:draft, fandom_string: "Testing4") }

    before do
      series.works = [unrestricted_work, restricted_work, hidden_work, draft_work]
      series.reload
    end

    shared_examples "only returns fandoms on unrestricted and restricted works" do
      it "returns fandoms on unrestricted, unhidden works" do
        expect(series.fandoms).to include(*unrestricted_work.fandoms)
      end

      it "returns fandoms on restricted works" do
        expect(series.fandoms).to include(*restricted_work.fandoms)
      end

      it "does not return fandoms on hidden works" do
        expect(series.fandoms).not_to include(*hidden_work.fandoms)
      end

      it "does not return fandoms on draft works" do
        expect(series.fandoms).not_to include(*draft_work.fandoms)
      end
    end

    context "when logged out" do
      it "returns fandoms on unrestricted, unhidden works" do
        expect(series.fandoms).to include(*unrestricted_work.fandoms)
      end

      it "does not return fandoms on restricted works" do
        expect(series.fandoms).not_to include(*restricted_work.fandoms)
      end

      it "does not return fandoms on hidden works" do
        expect(series.fandoms).not_to include(*hidden_work.fandoms)
      end

      it "does not return fandoms on draft works" do
        expect(series.fandoms).not_to include(*draft_work.fandoms)
      end

      context "when the series has no unrestricted works" do
        before do
          series.works -= [unrestricted_work]
          series.reload
        end

        it "returns an empty list" do
          expect(series.fandoms).to eq([])
        end
      end
    end

    context "when logged in as a regular user" do
      before do
        User.current_user = create(:user)
      end

      it_behaves_like "only returns fandoms on unrestricted and restricted works"
    end

    context "when loggged in as an admin" do
      before do
        User.current_user = create(:admin)
      end

      it_behaves_like "only returns fandoms on unrestricted and restricted works"
    end
  end

  describe "#tag_groups" do
    let(:restricted_work) { create(:work, restricted: true, freeform_string: "Testing2") }
    let(:hidden_work) { create(:work, hidden_by_admin: true, freeform_string: "Testing3") }
    let(:draft_work) { create(:draft, freeform_string: "Testing4") }

    before do
      series.works = [unrestricted_work, restricted_work, hidden_work, draft_work]
      series.reload
    end

    shared_examples "only includes tags on unrestricted and restricted works" do
      it "returns tags on unrestricted, unhidden works" do
        expect(series.tag_groups["Freeform"]).to include(*unrestricted_work.freeforms)
      end

      it "returns tags on restricted works" do
        expect(series.tag_groups["Freeform"]).to include(*restricted_work.freeforms)
      end

      it "does not return tags on hidden words" do
        expect(series.tag_groups["Freeform"]).not_to include(*hidden_work.freeforms)
      end

      it "does not return tags on draft words" do
        expect(series.tag_groups["Freeform"]).not_to include(*draft_work.freeforms)
      end
    end

    context "when no user is logged in" do
      it "returns tags on unrestricted, unhidden works" do
        expect(series.tag_groups["Freeform"]).to include(*unrestricted_work.freeforms)
      end

      it "does not return tags on restricted works" do
        expect(series.tag_groups["Freeform"]).not_to include(*restricted_work.freeforms)
      end

      it "does not return tags on hidden words" do
        expect(series.tag_groups["Freeform"]).not_to include(*hidden_work.freeforms)
      end

      it "does not return tags on draft words" do
        expect(series.tag_groups["Freeform"]).not_to include(*draft_work.freeforms)
      end
    end

    context "when logged in as a regular user" do
      before do
        User.current_user = create(:user)
      end

      it_behaves_like "only includes tags on unrestricted and restricted works"
    end

    context "when loggged in as an admin" do
      before do
        User.current_user = create(:admin)
      end

      it_behaves_like "only includes tags on unrestricted and restricted works"
    end
  end

  describe "when associations are preloaded for blurbs" do
    let(:hidden_work) { create(:work, hidden_by_admin: true, freeform_string: "Testing3") }
    let(:draft_work) { create(:draft, freeform_string: "Testing4") }
    let(:preloaded_series) { Series.for_blurb.find(series.id) }

    before do
      series.works = [unrestricted_work, restricted_work, hidden_work, draft_work]
      # Stagger the dates so the examples can tell which works each
      # revised_at branch uses (the column only has second precision).
      series.works.each_with_index do |work, index|
        work.update_column(:revised_at, (index + 1).days.from_now)
      end
      series.reload
    end

    it "preloads the works and their tags" do
      expect(preloaded_series.works).to be_loaded
      expect(preloaded_series.works.first.association(:tags)).to be_loaded
    end

    shared_examples "matches the results without preloading" do
      it "returns the same tag groups" do
        expect(preloaded_series.tag_groups.keys).to match_array(series.tag_groups.keys)
        series.tag_groups.each_pair do |type, tags|
          expect(preloaded_series.tag_groups[type]).to match_array(tags)
        end
      end

      it "returns the same visible work count" do
        expect(preloaded_series.visible_work_count).to eq(series.visible_work_count)
      end

      it "returns the same visible word count" do
        expect(preloaded_series.visible_word_count).to eq(series.visible_word_count)
      end

      it "returns the same revised date" do
        expect(preloaded_series.revised_at).to eq(series.revised_at)
      end
    end

    context "when no user is logged in" do
      it_behaves_like "matches the results without preloading"
    end

    context "when logged in as a regular user" do
      before do
        User.current_user = create(:user)
      end

      it_behaves_like "matches the results without preloading"
    end

    context "when logged in as an admin" do
      before do
        User.current_user = create(:admin)
      end

      it_behaves_like "matches the results without preloading"
    end

    context "when the logged-in user created a work hidden by an admin" do
      let(:owner) { create(:user) }
      let(:hidden_work) { create(:work, hidden_by_admin: true, authors: [owner.default_pseud]) }

      before do
        hidden_work.update_column(:revised_at, 10.days.from_now)
        User.current_user = owner
      end

      it "includes the hidden work's revision date" do
        expect(preloaded_series.revised_at).to eq(hidden_work.reload.revised_at)
      end
    end

    context "when a work has no word count" do
      before do
        unrestricted_work.update_column(:word_count, nil)
      end

      it "returns the same visible word count" do
        expect(preloaded_series.visible_word_count).to eq(series.visible_word_count)
      end
    end

    context "when a guest views a series with only restricted works" do
      before do
        series.works = [restricted_work]
        series.reload
      end

      it "falls back to the series update date" do
        expect(preloaded_series.revised_at).to eq(series.updated_at)
      end
    end
  end

  describe "#general_tags" do
    it "includes tags on unrestricted works" do
      series.works = [unrestricted_work]
      series.reload
      expect(series.general_tags).to include(*unrestricted_work.tags.pluck(:name))
    end

    it "includes tags on restricted works" do
      series.works = [restricted_work]
      series.reload
      expect(series.general_tags).to include(*restricted_work.tags.pluck(:name))
    end

    it "does not include tags on works hidden by an admin" do
      hidden_work = create(:work, hidden_by_admin: true)
      series.works = [hidden_work]
      series.reload
      expect(series.general_tags).to be_empty
    end
  end

  describe "#public_tags" do
    it "includes tags on unrestricted works" do
      series.works = [unrestricted_work]
      series.reload
      expect(series.public_tags).to include(*unrestricted_work.tags.pluck(:name))
    end

    it "does not include tags on restricted works" do
      series.works = [restricted_work]
      series.reload
      expect(series.public_tags).to be_empty
    end

    it "does not include tags on works hidden by an admin" do
      hidden_work = create(:work, hidden_by_admin: true)
      series.works = [hidden_work]
      series.reload
      expect(series.public_tags).to be_empty
    end
  end

  describe "#general_filter_ids" do
    it "includes tags on unrestricted works" do
      series.works = [unrestricted_work]
      series.reload
      expect(series.general_filter_ids).to include(*unrestricted_work.tags.canonical.pluck(:id))
    end

    it "includes tags on restricted works" do
      series.works = [restricted_work]
      series.reload
      expect(series.general_filter_ids).to include(*restricted_work.tags.canonical.pluck(:id))
    end

    it "does not include tags on works hidden by an admin" do
      hidden_work = create(:work, hidden_by_admin: true, character_string: create(:canonical_character).name)
      series.works = [hidden_work]
      series.reload
      expect(series.general_filter_ids).to be_empty
    end
  end

  describe "#public_filter_ids" do
    it "includes tags on unrestricted works" do
      series.works = [unrestricted_work]
      series.reload
      expect(series.public_filter_ids).to include(*unrestricted_work.tags.canonical.pluck(:id))
    end

    it "does not include tags on restricted works" do
      series.works = [restricted_work]
      series.reload
      expect(series.public_filter_ids).to be_empty
    end

    it "does not include tags on works hidden by an admin" do
      hidden_work = create(:work, hidden_by_admin: true, character_string: create(:canonical_character).name)
      series.works = [hidden_work]
      series.reload
      expect(series.public_filter_ids).to be_empty
    end
  end

  describe "#general_direct_filters" do
    let(:meta) { create(:canonical_character) }

    before do
      unrestricted_character.meta_tags << meta
      restricted_character.meta_tags << meta
    end

    it "includes direct tags on unrestricted works" do
      series.works = [unrestricted_work]
      series.reload
      expect(series.general_direct_filters).to include(*unrestricted_work.tags.canonical)
      expect(series.general_direct_filters).not_to include(meta)
    end

    it "includes direct tags on restricted works" do
      series.works = [restricted_work]
      series.reload
      expect(series.general_direct_filters).to include(*restricted_work.tags.canonical)
      expect(series.general_direct_filters).not_to include(meta)
    end

    it "does not include tags on works hidden by an admin" do
      hidden_work = create(:work, hidden_by_admin: true, character_string: create(:canonical_character).name)
      series.works = [hidden_work]
      series.reload
      expect(series.general_direct_filters).to be_empty
    end
  end

  describe "#public_direct_filters" do
    let(:meta) { create(:canonical_character) }

    before do
      unrestricted_character.meta_tags << meta
      restricted_character.meta_tags << meta
    end

    it "includes direct tags on unrestricted works" do
      series.works = [unrestricted_work]
      series.reload
      expect(series.public_direct_filters).to include(*unrestricted_work.tags.canonical)
      expect(series.public_direct_filters).not_to include(meta)
    end

    it "does not include tags on restricted works" do
      series.works = [restricted_work]
      series.reload
      expect(series.public_direct_filters).to be_empty
    end

    it "does not include tags on works hidden by an admin" do
      hidden_work = create(:work, hidden_by_admin: true, character_string: create(:canonical_character).name)
      series.works = [hidden_work]
      series.reload
      expect(series.public_direct_filters).to be_empty
    end
  end
end
