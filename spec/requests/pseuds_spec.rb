require "spec_helper"

describe "Pseuds" do
  subject { page }

  describe "show" do
    let(:user) { create(:user, login: "Agrajag") }

    before do
      create(:pseud, user: user, name: "Zaphod")
      create(:pseud, user: user, name: "Slartibartfast")
      create(:pseud, user: user, name: "Betelgeuse")
    end

    it "shows only the configured maximum number of pseuds" do
      allow(Pseud).to receive(:per_page).and_return(3)

      visit "/users/Agrajag/pseuds"

      within("ol.pagination", match: :first) do
        is_expected.to have_content("Next")
        is_expected.to have_content("1")
        is_expected.to have_link("2")
      end

      within("ul.pseud.index.group") do
        is_expected.to have_content("Agrajag")
        is_expected.to have_content("Betelgeuse")
        is_expected.to have_content("Slartibartfast")
        is_expected.not_to have_content("Zaphod")
      end
    end

    it "doesn't show pagination UI when there are fewer pseuds than the limit" do
      visit "/users/Agrajag/pseuds"

      is_expected.to_not have_css("ol.pagination")
    end
  end
end
