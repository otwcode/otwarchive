shared_examples "an action authorized admins can access" do |roles_that_are_authorized|
  roles_that_are_authorized ||= []
  before { fake_login_admin(admin) }

  roles_that_are_authorized.each do |role|
    context "with role #{role}" do
      let(:admin) { create(:admin, roles: [role]) }

      it "succeeds" do
        subject

        success_admin ||= expect(response.status).to eq(200)
      end
    end
  end
end

shared_examples "an action unauthorized admins cannot access" do |roles_that_are_authorized|
  roles_that_are_authorized ||= []
  before { fake_login_admin(admin) }

  context "with no role" do
    let(:admin) { create(:admin, roles: []) }

    it "redirects with an error" do
      subject

      access_denied_admin ||= it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
    end
  end

  (Admin::VALID_ROLES - roles_that_are_authorized).each do |role|
    context "with role #{role}" do
      let(:admin) { create(:admin, roles: [role]) }

      it "redirects with an error" do
        subject

        access_denied_admin ||= it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end
  end
end

shared_examples "an action only authorized admins can access" do |authorized_roles|
  authorized_roles ||= []
  roles = authorized_roles
  it_behaves_like "an action authorized admins can access", roles
  it_behaves_like "an action unauthorized admins cannot access", roles
end

shared_examples "an action guests cannot access" do
  it "redirects with error" do
    subject

    access_denied_guest ||= it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
  end
end

shared_examples "an action users cannot access" do
  before { fake_login }
  it "redirects with error" do
    subject

    access_denied_user ||= it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
  end
end

shared_examples "denies access for work that isn't visible to user" do
  shared_examples "denies access to random user" do
    it "allows access for work creator" do
      fake_login_known_user(creator)
      subject

      success
    end

    it "redirects other user" do
      fake_login
      subject

      it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
    end

    it "allows access for admin" do
      fake_login_admin(create(:admin))
      subject

      success_admin
    end
  end

  let(:creator) { create(:user) }

  context "hidden work" do
    let(:work) { create(:work, authors: [creator.default_pseud], hidden_by_admin: true) }

    include_examples "denies access to random user"
  end

  context "unrevealed work" do
    let(:work) { create(:work, authors: [creator.default_pseud], collections: [create(:unrevealed_collection)]) }

    include_examples "denies access to random user"
  end

  context "hidden and unrevealed work" do
    let(:work) { create(:work, authors: [creator.default_pseud], collections: [create(:unrevealed_collection)], hidden_by_admin: true) }

    include_examples "denies access to random user"
  end

  context "draft work" do
    let(:work) { create(:draft, authors: [creator.default_pseud]) }

    include_examples "denies access to random user"
  end
end
