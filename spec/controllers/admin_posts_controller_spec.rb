require "spec_helper"

describe AdminPostsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "POST #create" do
    before { fake_login_admin(create(:admin, roles: ["communications"])) }

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

  describe 'POST #update' do
    before(:all) do
      @admin = create(:admin)
      @post = create(:admin_post)
    end

    context "updating post" do
      context 'when admin does not have correct authorization' do
        it "denies random admin access" do
          @admin.update(roles: [])
          fake_login_admin(@admin)
          put :update, params: { id: @post.id, admin_post: { admin_id: @admin.id, title: 'Modified Title of Post' } }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context 'when admin has correct roles' do
        it "allows access to authorized admins and updates admin post" do
          @admin.update(roles: ['communications'])
          fake_login_admin(@admin)
          put :update, params: { id: @post.id, admin_post: { admin_id: @admin.id, title: 'Modified Title of Post' } }
          it_redirects_to_with_notice(admin_post_path(assigns[:admin_post]), "Admin Post was successfully updated.")
        end
      end
    end
  end

  describe 'GET #edit' do
    before(:all) do
      @admin = create(:admin)
      @post = create(:admin_post)
    end

    context 'when admin does not have correct authorization' do
      it "denies random admin access" do
        @admin.update(roles: [])
        fake_login_admin(@admin)
        get :edit, params: { id: @post.id }
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context 'when admin does not have correct authorization' do
      it "allows access to authorized admins and renders edit template" do
        @admin.update(roles: ['communications'])
        fake_login_admin(@admin)
        get :edit, params: { id: @post.id }
        expect(response).to render_template(:edit)
      end
    end
  end
end
