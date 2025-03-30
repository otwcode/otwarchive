# frozen_string_literal: true

require "spec_helper"

describe PseudsController do
  include LoginMacros
  include RedirectExpectationHelper

  shared_examples "an action unauthorized admins can't access" do |authorized_roles:|
    before { fake_login_admin(admin) }

    context "with no role" do
      let(:admin) { create(:admin, roles: []) }

      it "redirects with an error" do
        subject.call
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - authorized_roles).each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with an error" do
          subject.call
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end
  end

  shared_examples "an action admins can't access" do
    before { fake_login_admin(admin) }

    context "with no role" do
      let(:admin) { create(:admin, roles: []) }

      it "redirects with an error" do
        subject.call
        it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    Admin::VALID_ROLES.each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with an error" do
          subject.call
          it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        end
      end
    end
  end

  let(:user) { create(:user) }
  let(:pseud) { user.pseuds.first }

  describe "edit" do
    subject { -> { get :edit, params: { user_id: user, id: pseud } } }

    context "when logged in as admin" do
      authorized_roles = %w[policy_and_abuse superadmin]

      it_behaves_like "an action unauthorized admins can't access",
                      authorized_roles: authorized_roles

      authorized_roles.each do |role|
        context "with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          before { fake_login_admin(admin) }

          it "renders edit template" do
            subject.call
            expect(response).to render_template(:edit)
          end

          it "returns NotFound error when pseud doesn't exist" do
            expect { get :edit, params: { user_id: user, id: "fake_pseud" } }
              .to raise_error(ActiveRecord::RecordNotFound)
          end

          it "returns NotFound error when user doesn't exist" do
            expect { get :edit, params: { user_id: "fake_user", id: pseud } }
              .to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end

    context "when logged in as user" do
      before { fake_login_known_user(user) }

      it "returns NotFound error when pseud doesn't exist" do
        expect { get :edit, params: { user_id: user, id: "fake_pseud" } }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "update" do
    shared_examples "an attribute that can be updated by an admin" do
      it "redirects to user_pseud_path with notice" do
        put :update, params: params
        it_redirects_to_with_notice(user_pseud_path(user, pseud), "Pseud was successfully updated.")
      end

      it "creates admin activity" do
        expect do
          put :update, params: params
        end.to change { AdminActivity.count }
          .by(1)
        expect(AdminActivity.last.target).to eq(pseud)
        expect(AdminActivity.last.admin).to eq(admin)
        expect(AdminActivity.last.summary).to eq("<a href=\"#{ticket_url}\">Ticket #1</a> for User ##{user.id}")
      end
    end

    subject { -> { put :update, params: { user_id: user, id: pseud } } }

    context "when logged in as admin" do
      authorized_roles = %w[policy_and_abuse superadmin]

      before { fake_login_admin(admin) }

      it_behaves_like "an action unauthorized admins can't access",
                      authorized_roles: authorized_roles

      authorized_roles.each do |role|
        context "with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          context "with valid ticket number" do
            let(:ticket_url) { Faker::Internet.url }

            before do
              allow_any_instance_of(ZohoResourceClient).to receive(:find_ticket)
                .and_return({ "status" => "Open", "departmentId" => ArchiveConfig.ABUSE_ZOHO_DEPARTMENT_ID })
              allow_any_instance_of(Pseud).to receive(:ticket_url).and_return(ticket_url)
            end

            context "with description" do
              let(:params) { { user_id: user, id: pseud, pseud: { description: "admin edit", ticket_number: 1 } } }

              it_behaves_like "an attribute that can be updated by an admin"

              it "updates pseud description" do
                expect do
                  put :update, params: params
                end.to change { pseud.reload.description }
                  .from(nil)
                  .to("<p>admin edit</p>")
              end
            end

            context "with delete_icon" do
              let(:params) { { user_id: user, id: pseud, pseud: { delete_icon: "1", ticket_number: 1 } } }

              before do
                pseud.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
              end

              it_behaves_like "an attribute that can be updated by an admin"

              it "removes pseud icon" do
                expect do
                  put :update, params: params
                end.to change { pseud.reload.icon.attached? }
                  .from(true)
                  .to(false)
              end
            end

            %w[name icon_alt_text icon_comment_text].each do |attr|
              context "with #{attr}" do
                let(:params) { { user_id: user, id: pseud, pseud: { "#{attr}": "admin edit", ticket_number: 1 } } }

                it "raises UnpermittedParameters and does not update #{attr} or create admin activity" do
                  expect do
                    put :update, params: params
                  end.to raise_exception(ActionController::UnpermittedParameters)
                  expect(pseud.reload.send(attr)).not_to eq("admin edit")
                  expect(AdminActivity.last).to be_nil
                end
              end
            end

            context "with is_default" do
              let(:params) { { user_id: user, id: pseud, pseud: { is_default: "0", ticket_number: 1 } } }

              it "raises UnpermittedParameters and does not update is_default or create admin activity" do
                expect do
                  put :update, params: params
                end.to raise_exception(ActionController::UnpermittedParameters)
                expect(pseud.reload.is_default).not_to be_falsy
                expect(AdminActivity.last).to be_nil
              end
            end
          end
        end
      end
    end
  end

  describe "destroy" do
    subject { -> { post :destroy, params: { user_id: user, id: pseud } } }

    context "when logged in as admin" do
      it_behaves_like "an action admins can't access"
    end

    context "when logged in as user" do
      before do
        fake_login_known_user(user)
      end

      context "when deleting the default pseud" do
        it "errors and redirects to user_pseuds_path" do
          post :destroy, params: { user_id: user, id: user.default_pseud }
          it_redirects_to_with_error(user_pseuds_path(user), "You cannot delete your default pseudonym, sorry!")
        end
      end

      context "when deleting the pseud that matches your username" do
        it "errors and redirects to user_pseuds_path" do
          matching_pseud = user.default_pseud
          matching_pseud.update_attribute(:is_default, false)
          matching_pseud.reload

          post :destroy, params: { user_id: user, id: matching_pseud }
          it_redirects_to_with_error(user_pseuds_path(user), "You cannot delete the pseud matching your user name, sorry!")
        end
      end
    end
  end

  describe "new" do
    subject { -> { get :new, params: { user_id: user } } }

    context "when logged in as admin" do
      it_behaves_like "an action admins can't access"
    end
  end

  describe "create" do
    subject { -> { post :create, params: { user_id: user } } }

    context "when logged in as admin" do
      it_behaves_like "an action admins can't access"
    end
  end
end
