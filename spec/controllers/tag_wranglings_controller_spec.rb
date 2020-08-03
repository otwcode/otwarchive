require "spec_helper"

describe TagWranglingsController do
  include LoginMacros
  include RedirectExpectationHelper

  before do
    fake_login
    controller.current_user.roles << Role.new(name: "tag_wrangler")
  end

  describe "#wrangle" do
    let(:page_options) { { page: 1, sort_column: "name", sort_direction: "ASC" } }

    it "displays error when there are no fandoms to wrangle to" do
      character = create(:character, canonical: false)
      post :wrangle, params: { fandom_string: "", selected_tags: [character.id] }
      it_redirects_to_with_error(tag_wranglings_path(page_options), "There were no Fandom tags!")
    end
  end
end
