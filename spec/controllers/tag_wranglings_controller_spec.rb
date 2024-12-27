require "spec_helper"

describe TagWranglingsController do
  include LoginMacros
  include RedirectExpectationHelper

  full_access_roles = %w[superadmin tag_wrangling].freeze
  read_access_roles = %w[superadmin policy_and_abuse tag_wrangling].freeze

  shared_examples "an action only authorized admins can access" do |authorized_roles:|
    before do
      fake_login_admin(admin)
    end

    context "when logged in as an admin with no role" do
      let(:admin) { create(:admin) }

      it "redirects with an error" do
        subject
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - authorized_roles).each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        it "redirects with an error" do
          subject
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    authorized_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        it "succeeds" do
          subject
          success
        end
      end
    end
  end

  describe "GET #index" do
    let(:success) { expect(response).to have_http_status(:success) }

    context "when the show parameter is absent" do
      subject { get :index }

      it_behaves_like "an action only authorized admins can access", authorized_roles: read_access_roles

      context "when logged in as a tag wrangler" do
        before do
          fake_login_known_user(create(:tag_wrangler))
        end

        it "shows the wrangling tools page" do
          subject
          success
        end
      end
    end

    context "when the show parameter is present" do
      subject { get :index, params: { show: "fandoms" } }

      it_behaves_like "an action only authorized admins can access", authorized_roles: read_access_roles

      context "when logged in as a tag wrangler" do
        before do
          fake_login_known_user(create(:tag_wrangler))
        end

        it "shows the wrangling tools page" do
          subject
          success
        end
      end
    end
  end

  describe "POST #wrangle" do
    shared_examples "set last wrangling activity" do
      before do
        fake_login_known_user(create(:tag_wrangler))
        subject
      end

      it "sets the last wrangling activity time to now", :frozen do
        user = controller.current_user
        expect(user.last_wrangling_activity.updated_at).to eq(Time.now.utc)
      end
    end

    it "displays error when there are no fandoms to wrangle to" do
      fake_login_known_user(create(:tag_wrangler))
      character = create(:character)
      page_options = { page: 1, sort_column: "name", sort_direction: "ASC" }
      post :wrangle, params: { fandom_string: "", selected_tags: [character.id] }
      it_redirects_to_with_error(tag_wranglings_path(page_options), "There were no Fandom tags!")
    end

    context "when making tags canonical" do
      subject { post :wrangle, params: { canonicals: [tag1.id, tag2.id] } }
      let(:tag1) { create(:character) }
      let(:tag2) { create(:character) }
      let(:success) do
        expect(tag1.reload.canonical?).to be(true)
        expect(tag2.reload.canonical?).to be(true)
      end

      it_behaves_like "set last wrangling activity"
      it_behaves_like "an action only authorized admins can access", authorized_roles: full_access_roles
    end

    context "when assigning tags to a medium" do
      subject { post :wrangle, params: { media: medium.name, selected_tags: [fandom1.id, fandom2.id] } }
      let(:fandom1) { create(:fandom, canonical: true) }
      let(:fandom2) { create(:fandom, canonical: true) }
      let(:medium) { create(:media) }
      let(:success) do
        expect(fandom1.medias).to include(medium)
        expect(fandom2.medias).to include(medium)
      end

      it_behaves_like "set last wrangling activity"
      it_behaves_like "an action only authorized admins can access", authorized_roles: full_access_roles
    end

    context "when adding tags to a fandom" do
      subject { post :wrangle, params: { fandom_string: fandom.name, selected_tags: [tag1.id, tag2.id] } }
      let(:tag1) { create(:character) }
      let(:tag2) { create(:character) }
      let(:fandom) { create(:fandom, canonical: true) }
      let(:success) do
        expect(tag1.fandoms).to include(fandom)
        expect(tag2.fandoms).to include(fandom)
      end

      it_behaves_like "set last wrangling activity"
      it_behaves_like "an action only authorized admins can access", authorized_roles: full_access_roles
    end
  end
end
