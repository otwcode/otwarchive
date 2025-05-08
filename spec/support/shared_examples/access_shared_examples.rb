shared_examples "an action only authorized admins can access" do |authorized_roles:|
  before { fake_login_admin(admin) }

  context "with no role" do
    let(:admin) { create(:admin, roles: []) }

    it "redirects with an error" do
      subject
      it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
    end
  end

  (Admin::VALID_ROLES - authorized_roles).each do |role|
    context "with role #{role}" do
      let(:admin) { create(:admin, roles: [role]) }

      it "redirects with an error" do
        subject
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end
  end

  authorized_roles.each do |role|
    context "with role #{role}" do
      let(:admin) { create(:admin, roles: [role]) }

      it "succeeds" do
        subject
        success
      end
    end
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
end
