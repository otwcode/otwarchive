require 'spec_helper'

describe "Profile", type: :request do
  subject { page }

  describe "show" do
    let(:user) { FactoryBot.create(:user, login: "Zaphod") }

    before do
      FactoryBot.create(:pseud, user: user, name: "Slartibartfast")
      FactoryBot.create(:pseud, user: user, name: "Agrajag")
      FactoryBot.create(:pseud, user: user, name: "Betelgeuse")
      allow(ArchiveConfig).to receive(:ITEMS_PER_PAGE).and_return(3)
    end

    it "shows only the configured maximum number of pseuds" do
      visit "/users/Zaphod/profile"

      within("dl.meta") do
        is_expected.to have_content("Zaphod")
        is_expected.to have_content("Agrajag")
        is_expected.to have_content("Betelgeuse")
        is_expected.not_to have_content("Slartibartfast")
        is_expected.to have_content("All my pseuds (4)")
      end
    end
  end
end
