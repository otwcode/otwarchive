require "spec_helper"

describe PseudSearchForm do
  let(:fandom_kp) { create(:fandom) }
  let(:fandom_mlaatr) { create(:fandom) }

  context "searching pseuds in a fandom" do
    let!(:work_1) { create(:posted_work, fandoms: [fandom_kp]) }
    let!(:work_2) { create(:posted_work, fandoms: [fandom_kp], restricted: true) }
    let!(:work_3) { create(:posted_work, fandoms: [fandom_mlaatr]) }
    let!(:work_4) { create(:posted_work, fandoms: [fandom_mlaatr], restricted: true) }

    before { update_and_refresh_indexes "pseud" }

    it "returns all pseuds writing in the fandom when logged in" do
      User.current_user = User.new
      results = PseudSearchForm.new(fandom: fandom_kp.name).search_results
      expect(results).to include work_1.pseuds.first
      expect(results).to include work_2.pseuds.first
      expect(results).not_to include work_3.pseuds.first
      expect(results).not_to include work_4.pseuds.first
    end

    it "returns pseuds writing public works in the fandom" do
      results = PseudSearchForm.new(fandom: fandom_kp.name).search_results
      expect(results).to include work_1.pseuds.first
      expect(results).not_to include work_2.pseuds.first
      expect(results).not_to include work_3.pseuds.first
      expect(results).not_to include work_4.pseuds.first
    end
  end

  context "searching pseuds in multiple fandoms" do
    let(:user) { create(:user) }

    let!(:work_1) { create(:posted_work, fandoms: [fandom_kp, fandom_mlaatr]) }
    let!(:work_2) { create(:posted_work, fandoms: [fandom_kp], authors: [user.default_pseud]) }
    let!(:work_3) { create(:posted_work, fandoms: [fandom_mlaatr], authors: [user.default_pseud], restricted: true) }

    before { update_and_refresh_indexes "pseud" }

    it "returns all pseuds writing in all fandoms" do
      User.current_user = User.new
      results = PseudSearchForm.new(fandom: "#{fandom_kp.name},#{fandom_mlaatr.name}").search_results
      expect(results).to include work_1.pseuds.first
      expect(results).to include user.default_pseud
    end

    it "returns pseuds writing public works in all fandoms" do
      results = PseudSearchForm.new(fandom: "#{fandom_kp.name},#{fandom_mlaatr.name}").search_results
      expect(results).to include work_1.pseuds.first
      # This author posts in both fandoms, but their only work for fandom_mlaatr is restricted.
      # To logged out users, this author does not post in both specified fandoms.
      expect(results).not_to include user.default_pseud
    end
  end
end
