require 'spec_helper'

describe "Users", type: :request do
  subject { page }

  describe "show" do
    let(:user) { FactoryBot.create(:user, login: "Zaphod") }

    before do
      FactoryBot.create(:pseud, user: user, name: "Slartibartfast")
      FactoryBot.create(:pseud, user: user, name: "Agrajag")
      FactoryBot.create(:pseud, user: user, name: "Betelgeuse")
      allow(ArchiveConfig).to receive(:ITEMS_PER_PAGE).and_return(3)
    end

    it "shows a maximum of pseuds in the sidebar selector" do
      visit "/users/Zaphod"

      within("ul.expandable") do
        is_expected.to have_content("Zaphod")
        is_expected.to have_content("Agrajag")
        is_expected.to have_content("Betelgeuse")
        is_expected.not_to have_content("Slartibartfast")
        is_expected.to have_content("All Pseuds (4)")
      end
    end

    it "always shows the current pseud above the selector" do
      visit "/users/Zaphod/pseuds/Slartibartfast"

      within("li.pseud > a") do
        is_expected.to have_content("Slartibartfast")
      end

      within("ul.expandable") do
        is_expected.not_to have_content("Slartibartfast")
      end
    end
  end
end
