# frozen_string_literal: true

require "spec_helper"

describe Series do
  let(:unrestricted_work) { create(:work, restricted: false, freeform_string: "MyFreeform") }
  let(:restricted_work) { create(:work, restricted: true, freeform_string: "MyFreeform2") }
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
end
