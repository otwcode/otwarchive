require "spec_helper"

describe BylineHelper do
  describe "#byline" do
    let(:user1) { create(:user, login: "Beetle") }
    let(:user2) { create(:user, login: "Muppet") }
    let(:work) { create(:work, authors: [user1.default_pseud, user2.default_pseud]) }

    before do
      create(:locale, iso: "new")
      I18n.backend.store_translations(:new, { support: { array: { words_connector: "|" } } })
    end

    it "results in different bylines per locale" do
      I18n.with_locale(I18n.default_locale) do
        expect(helper.byline(work, visibility: "public")).to include("Beetle</a>, <a")
      end

      I18n.with_locale(:new) do
        expect(helper.byline(work, visibility: "public")).to include("Beetle</a>|<a")
      end
    end
  end
end
