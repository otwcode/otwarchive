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
