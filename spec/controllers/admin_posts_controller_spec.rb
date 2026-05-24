require "spec_helper"

describe AdminPostsController do
  include LoginMacros
  include RedirectExpectationHelper

  posting_roles = %w[superadmin board board_assistants_team communications support translation].freeze
  drafting_roles = (posting_roles | %w[policy_and_abuse]).freeze

  describe "GET #index" do
    context "when filtering by language" do
      let(:translated_post1) { create(:admin_post, tag_list: "xylophone,aardvark") }
      let!(:translation_post1) { create(:admin_post, translated_post_id: translated_post1.id, language: create(:language, short: "fr")) }
      let(:translated_post2) { create(:admin_post, tag_list: "xylophone,aardvark") }
      let!(:translation_post2) { create(:admin_post, translated_post_id: translated_post2.id, language: translation_post1.language) }
      let!(:untranslated_post) { create(:admin_post, tag_list: "uncommon tag") }

      it "assigns the admin post tags for the language ordered by name" do
        get :index, params: { language_id: "fr" }

        expect(assigns[:tags].map(&:name).join(", ")).to eql("aardvark, xylophone")
      end
    end
  end

  describe "GET #drafts" do
    subject { get :drafts }
    let(:success) { expect(response).to render_template(:drafts) }

    it_behaves_like "an action only authorized admins can access", authorized_roles: drafting_roles
    it_behaves_like "an action that non-admins cannot access"
  end

  describe "GET #show" do
    context "when admin post is a draft" do
      let(:admin_post) { create(:admin_post, :draft) }
      subject { get :show, params: { id: admin_post.id } }
      let(:success) { expect(response).to render_template(:show) }

      it_behaves_like "an action only authorized admins can access", authorized_roles: drafting_roles
      it_behaves_like "an action that non-admins cannot access"
    end

    context "when admin post does not exist" do
      it "raises an error" do
        expect do
          get :show, params: { id: "999999999" }
        end.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "GET #preview" do
    subject { get :preview, params: { id: admin_post.id } }
    let(:success) { expect(response).to render_template(:preview) }

    context "when admin post is a draft" do
      let(:admin_post) { create(:admin_post, :draft) }

      it_behaves_like "an action only authorized admins can access", authorized_roles: drafting_roles
      it_behaves_like "an action that non-admins cannot access"
    end

    context "when admin post is not a draft" do
      let(:admin_post) { create(:admin_post) }

      it_behaves_like "an action only authorized admins can access", authorized_roles: posting_roles
      it_behaves_like "an action that non-admins cannot access"
    end

    context "when admin post does not exist" do
      it "raises an error" do
        fake_login_admin(create(:superadmin))
        expect do
          get :preview, params: { id: "999999999" }
        end.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "GET #new" do
    subject { get :new }
    let(:success) { expect(response).to render_template(:new) }

    it_behaves_like "an action only authorized admins can access", authorized_roles: drafting_roles
    it_behaves_like "an action that non-admins cannot access"
  end

  describe "GET #edit" do
    subject { get :edit, params: { id: admin_post.id } }
    let(:success) { expect(response).to render_template(:edit) }

    context "when the post is a draft" do
      let(:admin_post) { create(:admin_post, :draft) }

      it_behaves_like "an action only authorized admins can access", authorized_roles: drafting_roles
      it_behaves_like "an action that non-admins cannot access"
    end

    context "when the post is not a draft" do
      let(:admin_post) { create(:admin_post) }

      it_behaves_like "an action only authorized admins can access", authorized_roles: posting_roles
      it_behaves_like "an action that non-admins cannot access"
    end
  end

  describe "POST #create" do
    let(:params) { { admin_post: { title: "AdminPost Title", content: "Cool new admin post content" } } }
    subject { post :create, params: params }
    let(:success) { it_redirects_to_with_notice(admin_post_path(assigns[:admin_post]), "Admin Post was successfully created.") }

    context "when admin post is valid" do
      context "when the post is a draft" do
        let(:params) { super().merge(save_button: "Save As Draft") }

        it_behaves_like "an action only authorized admins can access", authorized_roles: drafting_roles
        it_behaves_like "an action that non-admins cannot access"
      end

      context "when the post is not a draft" do
        let(:params) { super().merge(post_button: "Post") }

        it_behaves_like "an action only authorized admins can access", authorized_roles: posting_roles
        it_behaves_like "an action that non-admins cannot access"
      end

      context "when the post is previewed" do
        let(:params) { super().merge(preview_button: "Preview") }
        let(:success) do
          expect(response).to render_template(:preview)
          expect(AdminPost.count).to eql(0)
        end

        it_behaves_like "an action only authorized admins can access", authorized_roles: drafting_roles
        it_behaves_like "an action that non-admins cannot access"
      end

      context "with unposted translated post" do
        let(:admin_post) { create(:admin_post, :draft) }
        let(:params) { super().deep_merge(post_button: "Post", admin_post: { translated_post_id: admin_post.id, language_id: create(:language).id }) }
        before { fake_login_admin(create(:superadmin)) }

        it "will always be a draft" do
          subject

          it_redirects_to_with_notice(admin_post_path(assigns[:admin_post]), "Admin Post was successfully created.")
          expect(assigns[:admin_post].posted?).to be_falsey
        end
      end
    end

    context "when admin post is invalid" do
      let(:admin) { create(:superadmin) }
      before { fake_login_admin(admin) }

      context "with invalid translated post id" do
        let(:params) { super().deep_merge(admin_post: { translated_post_id: 0, language_id: create(:language).id }) }

        it "renders the new template with error message" do
          subject

          expect(response).to render_template(:new)
          expect(assigns[:admin_post].errors.full_messages).to include("Translated post does not exist")
        end

        context "with new tags" do
          let(:params) { super().deep_merge(admin_post: { tag_list: "badtag" }) }
          it "doesn't create new tags" do
            subject

            expect(AdminPostTag.find_by(name: "badtag")).to be_nil
          end
        end

        context "when the post is previewed" do
          let(:params) { super().merge(preview_button: "Preview") }

          it "renders the new template with error message" do
            subject

            expect(response).to render_template(:new)
            expect(assigns[:admin_post].errors.full_messages).to include("Translated post does not exist")
          end
        end
      end

      context "with invalid comment permissions" do
        it "renders the new template with error message" do
          post :create, params: params.deep_merge(admin_post: { comment_permissions: "Comment" })

          expect(response).to render_template(:new)
          expect(assigns[:admin_post].errors.full_messages).to include("Comment permissions are invalid.")
        end
      end

      context "when translated post has same language id" do
        let(:admin_post) { create(:admin_post) }
        let(:params) { super().deep_merge(admin_post: { translated_post_id: admin_post.id, language_id: admin_post.language_id }) }

        it "renders the new template with error message" do
          subject

          expect(response).to render_template(:new)
          expect(assigns[:admin_post].errors.full_messages).to include("Translated post cannot be same language as original post")
        end
      end
    end
  end

  describe "POST #update" do
    let(:admin_post) { create(:admin_post) }
    let(:post_params) { { title: "AdminPost Title", content: "Cool new admin post content" } }
    let(:params) { { id: admin_post.id, admin_post: post_params } }
    subject { put :update, params: params }
    let(:success) do
      it_redirects_to_with_notice(admin_post_path(assigns[:admin_post]), "Admin Post was successfully updated.")
      expect(admin_post.reload.content).to include(params[:admin_post][:content])
    end

    context "when admin post is valid" do
      context "when the post is a draft" do
        let(:admin_post) { create(:admin_post, :draft) }
        let(:params) { super().merge(save_button: "Save As Draft") }
        let(:success) do
          super()
          expect(assigns[:admin_post].draft?).to be_truthy
        end

        it_behaves_like "an action only authorized admins can access", authorized_roles: drafting_roles
        it_behaves_like "an action that non-admins cannot access"
      end

      context "when posting a draft" do
        let(:admin_post) { create(:admin_post, :draft) }
        let(:params) { super().merge(post_button: "Post") }
        let(:success) do
          super()
          expect(admin_post.reload.draft?).to be_falsey
        end

        it_behaves_like "an action only authorized admins can access", authorized_roles: posting_roles
        it_behaves_like "an action that non-admins cannot access"
      end

      context "when the post is not a draft" do
        let(:params) { super().merge(post_button: "Update") }

        it_behaves_like "an action only authorized admins can access", authorized_roles: posting_roles
        it_behaves_like "an action that non-admins cannot access"
      end

      context "when the post is previewed" do
        let(:params) { super().merge(preview_button: "Preview") }
        let(:success) do
          expect(response).to render_template(:preview)
          expect(admin_post.reload.content).to_not include(params[:admin_post][:content])
        end

        it_behaves_like "an action only authorized admins can access", authorized_roles: posting_roles
        it_behaves_like "an action that non-admins cannot access"
      end
    end

    context "with valid title" do
      let(:post_params) { super().merge(title: "Modified Title of Post") }
      let(:success) do
        super()
        expect(assigns[:admin_post].title).to eq("Modified Title of Post")
      end

      it_behaves_like "an action only authorized admins can access", authorized_roles: posting_roles
      it_behaves_like "an action that non-admins cannot access"
    end

    context "when admin has correct authorization" do
      posting_roles.each do |admin_role|
        context "with #{admin_role} role" do
          let(:admin) { create(:admin, roles: [admin_role]) }

          before { fake_login_admin(admin) }
          
          context "with invalid translated_post_id" do
            it "renders the edit template with error message" do
              put :update, params: { id: admin_post.id, admin_post: { admin_id: admin.id, translated_post_id: 0 } }

              expect(response).to render_template(:edit)
              expect(assigns[:admin_post].errors.full_messages).to include("Translated post does not exist")
            end
          end

          context "with valid translated_post_id" do
            let!(:translation) { create(:admin_post, translated_post_id: admin_post.id, language_id: create(:language).id) }

            context "with valid comment_permissions" do
              it "does not change comment_permissions and redirects with notice" do
                expect do
                  put :update, params: {
                    id: translation.id,
                    admin_post: {
                      admin_id: admin.id,
                      comment_permissions: :disable_all
                    }
                  }
                end.not_to change { AdminPost.comment_permissions }

                expect(translation.reload.comment_permissions).to eq(admin_post.comment_permissions)
                it_redirects_to_with_notice(admin_post_path(translation), "Admin Post was successfully updated.")
              end
            end

            context "with invalid translated_post language" do
              it "renders the edit template with error message" do
                put :update, params: { id: translation.id, admin_post: { admin_id: admin.id, language_id: admin_post.language_id } }
                expect(response).to render_template(:edit)
                expect(assigns[:admin_post].errors.full_messages).to include("Translated post cannot be same language as original post")
              end
            end

            context "when posting" do
              context "an unposted translated post" do
                let(:admin_post) { create(:admin_post, :draft) }
                let(:translation) { create(:admin_post, :draft, translated_post_id: admin_post.id, language_id: create(:language).id) }
  
                it "will remain a draft" do
                  put :update, params: { post_button: "Post", id: translation.id, admin_post: { admin_id: admin.id } }
  
                  it_redirects_to_with_notice(admin_post_path(assigns[:admin_post]), "Admin Post was successfully updated.")
                  expect(translation.reload.posted?).to be_falsey
                end
              end
            end
          end
        end
      end
    end
  end

  describe "POST #post" do
    let(:admin_post) { create(:admin_post, :draft) }
    subject { put :post, params: { id: admin_post.id } }
    let(:success) do
      it_redirects_to_with_notice(admin_post_path(admin_post), "Admin Post was successfully posted.")
      expect(admin_post.reload.posted).to be_truthy
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: posting_roles
    it_behaves_like "an action that non-admins cannot access"
  end

  describe "DELETE #destroy" do
    subject { delete :destroy, params: { id: admin_post.id } }

    context "when post is a draft" do
      let(:admin_post) { create(:admin_post, :draft) }
      let(:success) do
        expect do
          admin_post.reload
        end.to raise_exception(ActiveRecord::RecordNotFound)
        it_redirects_to(drafts_admin_posts_path)
      end

      it_behaves_like "an action only authorized admins can access", authorized_roles: drafting_roles
      it_behaves_like "an action that non-admins cannot access"

      context "with translated post" do
        let!(:translation) { create(:admin_post, :draft, translated_post_id: admin_post.id, language_id: create(:language).id) }
        let(:success) do
          expect do
            admin_post.reload
          end.to raise_exception(ActiveRecord::RecordNotFound)
          expect do
            translation.reload
          end.to raise_exception(ActiveRecord::RecordNotFound)
          it_redirects_to(drafts_admin_posts_path)
        end

        it_behaves_like "an action only authorized admins can access", authorized_roles: drafting_roles
        it_behaves_like "an action that non-admins cannot access"
      end
    end

    context "when post is not a draft" do
      let(:admin_post) { create(:admin_post) }
      let(:success) do
        expect do
          admin_post.reload
        end.to raise_exception(ActiveRecord::RecordNotFound)
        it_redirects_to(admin_posts_path)
      end

      context "with translated post" do
        let!(:translation) { create(:admin_post, translated_post_id: admin_post.id, language_id: create(:language).id) }
        let(:success) do
          expect do
            admin_post.reload
          end.to raise_exception(ActiveRecord::RecordNotFound)
          expect do
            translation.reload
          end.to raise_exception(ActiveRecord::RecordNotFound)
          it_redirects_to(admin_posts_path)
        end

        it_behaves_like "an action only authorized admins can access", authorized_roles: posting_roles
        it_behaves_like "an action that non-admins cannot access"
      end

      it_behaves_like "an action only authorized admins can access", authorized_roles: posting_roles
      it_behaves_like "an action that non-admins cannot access"
    end
  end
end
