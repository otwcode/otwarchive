require "spec_helper"

describe AdminPostsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "POST #create" do
    before { fake_login_admin(create(:admin)) }

    let(:base_params) { { title: "AdminPost Title",
                          content: "AdminPost content long enough to pass validation" } }

    context "when admin post is valid" do
      it "redirects to post with notice" do
        post :create, params: { admin_post: base_params }
        it_redirects_to_with_notice(admin_post_path(assigns[:admin_post]), "Admin Post was successfully created.")
      end
    end

    context "when admin post is invalid" do
      context "with invalid translated post id" do
        it "renders the new template with error message" do
          post :create, params: { admin_post: { translated_post_id: 0 } }.merge(base_params)
          expect(response).to render_template(:new)
          expect(assigns[:admin_post].errors.full_messages).to include("Translated post does not exist")
        end
      end
    end
  end
end
