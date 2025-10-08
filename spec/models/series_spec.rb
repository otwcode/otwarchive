# frozen_string_literal: true

require 'spec_helper'

describe Series do
  let(:unrestricted_character) { create(:canonical_character) }
  let(:restricted_character) { create(:canonical_character) }
  let(:unrestricted_work) { create(:work, restricted: false, character_string: unrestricted_character.name) }
  let(:restricted_work) { create(:work, restricted: true, character_string: restricted_character.name) }
  let(:series) { create(:series) }

  it "should be unrestricted when it has unrestricted works" do
    series.works = [unrestricted_work]
    series.reload
    expect(series.restricted).not_to be_truthy
  end

  it "should be restricted when it has no unrestricted works" do
    series.works = [restricted_work]
    series.reload
    expect(series.restricted).to be_truthy
  end

  it "should be unrestricted when it has both restricted and unrestricted works" do
    series.works = [restricted_work, unrestricted_work]
    series.reload
    expect(series.restricted).not_to be_truthy
  end

  it "has all of the pseuds from all of its serial works" do
    series.works = [restricted_work, unrestricted_work]
    series.reload
    expect(series.work_pseuds).to match_array(unrestricted_work.pseuds +
                                              restricted_work.pseuds)
    expect(series.pseuds).to include(*unrestricted_work.pseuds.to_a)
    expect(series.pseuds).to include(*restricted_work.pseuds.to_a)
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
      hidden_work = create(:work, hidden_by_admin: true)
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
      hidden_work = create(:work, hidden_by_admin: true)
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
