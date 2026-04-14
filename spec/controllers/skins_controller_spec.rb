# frozen_string_literal: true

require "spec_helper"

describe SkinsController do
  include LoginMacros
  include RedirectExpectationHelper

  manage_site_skin_roles = %w[superadmin].freeze
  manage_work_skin_roles = %w[superadmin support].freeze

  shared_examples "an action only the skin author can access" do
    context "when logged in as the skin author" do
      before { fake_login_known_user(skin.author) }

      it "succeeds" do
        subject
        success
      end
    end

    context "when logged in as a user who isn't the skin author" do
      before { fake_login }

      it "redirects with an error" do
        subject
        # This actually redirects to the logged in user's dashboard.
        it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged out" do
      it "redirects with an error" do
        subject
        # This actually redirects to the login page.
        it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end
  end

  shared_examples "an action users and guests can't access" do
    context "when logged in as the skin author" do
      before { fake_login_known_user(skin.author) }

      it "redirects with an error" do
        subject
        # This actually redirects to the logged in user's dashboard.
        it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to edit this skin")
      end
    end

    context "when logged in as a user who isn't the skin author" do
      before { fake_login }

      it "redirects with an error" do
        subject
        # This actually redirects to the logged in user's dashboard.
        it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged out" do
      it "redirects with an error" do
        subject
        # This actually redirects to the login page.
        it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end
  end

  describe "POST #create" do
    let(:skin_creator) { create(:user) }

    before do
      fake_login_known_user(skin_creator)
    end

    context "when duplicate database inserts happen despite Rails validations" do
      # https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of-label-Concurrency+and+integrity
      #
      # We fake this scenario by skipping Rails validations.
      before do
        allow_any_instance_of(Skin).to receive(:save).and_call_original
        allow_any_instance_of(Skin).to receive(:save).with(no_args) do |skin|
          skin.save(validate: false)
        end

        create(:skin, title: "hello world")
      end

      it "shows the usual validation error" do
        post :create, params: { skin: { title: "hello world" } }

        expect(response).to render_template(:new)
        expect(assigns[:skin]).not_to be_valid
        expect(assigns[:skin].errors[:title]).to include("must be unique")
      end
    end
  end

  describe "GET #edit" do
    subject { get :edit, params: { id: skin.id } }
    let(:success) { expect(response).to render_template(:edit) }

    context "with a site skin" do
      context "when the skin is public" do
        let(:skin) { create(:skin, :public) }

        it_behaves_like "an action only authorized admins can access", authorized_roles: manage_site_skin_roles
        it_behaves_like "an action users and guests can't access"
      end

      context "when the skin is not public" do
        let(:skin) { create(:skin) }

        it_behaves_like "an action only the skin author can access"
      end
    end

    context "with a work skin" do
      context "when the skin is public" do
        let(:skin) { create(:work_skin, :public) }

        it_behaves_like "an action only authorized admins can access", authorized_roles: manage_work_skin_roles
        it_behaves_like "an action users and guests can't access"
      end

      context "when the skin is not public" do
        let(:skin) { create(:work_skin) }

        it_behaves_like "an action only the skin author can access"
      end
    end
  end

  describe "PUT #update" do
    shared_examples "an action guests and random logged-in users can't access" do |attribute:, value:|
      context "when logged in as a user who is not the skin author" do
        before do
          fake_login
        end

        it "redirects with an error" do
          put :update, params: { id: skin.id, skin: { attribute => value } }
          it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to access the page you were trying to reach.")
          expect(skin.reload.send(attribute)).not_to eq(value)
        end
      end

      context "when logged out" do
        it "redirects with an error" do
          put :update, params: { id: skin.id, skin: { attribute => value } }
          it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
          expect(skin.reload.send(attribute)).not_to eq(value)
        end
      end
    end

    shared_examples "a skin that skin authors can no longer update" do |attribute:, value:|
      context "when logged in as the skin author" do
        context "with the official role" do
          before do
            skin.update!(author_id: create(:official_user).id)
            fake_login_known_user(skin.reload.author)
          end

          it "redirects with an error" do
            put :update, params: { id: skin.id, skin: { attribute => value } }
            it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to edit this skin")
            expect(skin.reload.send(attribute)).not_to eq(value)
          end
        end

        context "without the official role" do
          before do
            fake_login_known_user(skin.author)
          end

          it "redirects with an error" do
            put :update, params: { id: skin.id, skin: { attribute => value } }
            it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to edit this skin")
            expect(skin.reload.send(attribute)).not_to eq(value)
          end
        end
      end
    end

    shared_examples "an attribute skin authors can update" do |attribute:, value:|
      context "when logged in as the skin author" do
        before do
          fake_login_known_user(skin.author)
        end

        it "updates #{attribute}" do
          put :update, params: { id: skin.id, skin: { attribute => value } }
          expect(skin.reload.read_attribute_before_type_cast(attribute)).to eq(value)
          it_redirects_to_with_notice(skin_path(skin), "Skin was successfully updated.")
        end
      end
    end

    shared_examples "an attribute skin authors with the official role can update" do |attribute:, value:|
      context "when logged in as the skin author" do
        context "with the official role" do
          before do
            skin.update!(author_id: create(:official_user).id)
            fake_login_known_user(skin.reload.author)
          end

          it "updates #{attribute}" do
            put :update, params: { id: skin.id, skin: { attribute => value } }
            expect(skin.reload.read_attribute_before_type_cast(attribute)).to eq(value)
            it_redirects_to_with_notice(skin_path(skin), "Skin was successfully updated.")
          end
        end

        context "without the official role" do
          before do
            fake_login_known_user(skin.author)
          end

          it "raises an exception" do
            expect do
              put :update, params: { id: skin.id, skin: { attribute => value } }
            end.to raise_exception(ActionController::UnpermittedParameters)
            expect(skin.reload.send(attribute)).not_to eq(value)
          end
        end
      end
    end

    shared_examples "a skin admins can't update" do |attribute:, value:|
      before do
        fake_login_admin(admin)
      end

      context "when logged in as an admin with no role" do
        let(:admin) { create(:admin, roles: []) }

        it "redirects with an error" do
          put :update, params: { id: skin.id, skin: { attribute => value } }
          it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to edit this skin")
          expect(skin.reload.send(attribute)).not_to eq(value)
        end
      end

      Admin::VALID_ROLES.each do |role|
        context "when logged in as an admin with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "redirects with an error" do
            put :update, params: { id: skin.id, skin: { attribute => value } }
            it_redirects_to_with_error(skin_path(skin), "Sorry, you don't have permission to edit this skin")
            expect(skin.reload.send(attribute)).not_to eq(value)
          end
        end
      end
    end

    shared_examples "an attribute authorized admins can't update" do |authorized_roles:, attribute:, value:|
      before do
        fake_login_admin(admin)
      end

      context "when logged in as an admin with no role" do
        let(:admin) { create(:admin, roles: []) }

        it "redirects with an error" do
          put :update, params: { id: skin.id, skin: { attribute => value } }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
          expect(skin.reload.send(attribute)).not_to eq(value)
        end
      end

      (Admin::VALID_ROLES - authorized_roles).each do |role|
        context "when logged in as an admin with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "redirects with an error" do
            put :update, params: { id: skin.id, skin: { attribute => value } }
            it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
            expect(skin.reload.send(attribute)).not_to eq(value)
          end
        end
      end

      authorized_roles.each do |role|
        context "when logged in as an admin with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "raises an exception" do
            expect do
              put :update, params: { id: skin.id, skin: { attribute => value } }
            end.to raise_exception(ActionController::UnpermittedParameters)
            expect(skin.reload.send(attribute)).not_to eq(value)
          end
        end
      end
    end

    shared_examples "an attribute authorized admins can update" do |authorized_roles:, attribute:, value:|
      before do
        fake_login_admin(admin)
      end

      context "when logged in as an admin with no role" do
        let(:admin) { create(:admin, roles: []) }

        it "redirects with an error" do
          put :update, params: { id: skin.id, skin: { attribute => value } }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
          expect(skin.reload.send(attribute)).not_to eq(value)
        end
      end

      (Admin::VALID_ROLES - authorized_roles).each do |role|
        context "when logged in as an admin with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "redirects with an error" do
            put :update, params: { id: skin.id, skin: { attribute => value } }
            it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
            expect(skin.reload.send(attribute)).not_to eq(value)
          end
        end
      end

      authorized_roles.each do |role|
        context "when logged in as an admin with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "updates #{attribute}" do
            put :update, params: { id: skin.id, skin: { attribute => value } }
            expect(skin.reload.read_attribute_before_type_cast(attribute)).to eq(value)
            it_redirects_to_with_notice(skin_path(skin), "Skin was successfully updated.")
          end
        end
      end
    end

    context "with a site skin" do
      context "when the skin is public" do
        let(:skin) { create(:skin, :public) }

        {
          title: "Edited title",
          css: ".new {\n  content: none;\n}\n\n",
          description: "<p>Updated version.</p>",
          role: "override",
          ie_condition: Skin::IE_CONDITIONS.last,
          unusable: 1,
          font: "Helvetica",
          base_em: 80,
          margin: 15,
          paragraph_margin: 1.5,
          background_color: "white",
          foreground_color: "black",
          headercolor: "#900",
          accent_color: "#EEEEEE"
        }.each_pair do |attribute, value|
          context "with the #{attribute} param" do
            it_behaves_like "an attribute authorized admins can update",
                            authorized_roles: manage_site_skin_roles,
                            attribute: attribute,
                            value: value

            it_behaves_like "a skin that skin authors can no longer update",
                            attribute: attribute,
                            value: value

            it_behaves_like "an action guests and random logged-in users can't access",
                            attribute: attribute,
                            value: value
          end
        end

        { public: 0 }.each_pair do |attribute, value|
          context "with the #{attribute} param" do
            before do
              allow_any_instance_of(Skin).to receive(:valid_public_preview).and_return(true)
            end

            it_behaves_like "a skin that skin authors can no longer update",
                            attribute: attribute,
                            value: value

            it_behaves_like "an attribute authorized admins can't update",
                            authorized_roles: manage_site_skin_roles,
                            attribute: attribute,
                            value: value

            it_behaves_like "an action guests and random logged-in users can't access",
                            attribute: attribute,
                            value: value
          end
        end
      end

      context "when the skin is not public" do
        let(:skin) { create(:skin) }

        {
          title: "Edited title",
          css: ".new {\n  content: none;\n}\n\n",
          description: "<p>Updated version.</p>",
          role: "override",
          ie_condition: Skin::IE_CONDITIONS.last,
          unusable: 1,
          font: "Helvetica",
          base_em: 80,
          margin: 15,
          paragraph_margin: 1.5,
          background_color: "white",
          foreground_color: "black",
          headercolor: "#900",
          accent_color: "#EEEEEE"
        }.each_pair do |attribute, value|
          context "with the #{attribute} param" do
            it_behaves_like "an attribute skin authors can update",
                            attribute: attribute,
                            value: value

            it_behaves_like "a skin admins can't update",
                            attribute: attribute,
                            value: value

            it_behaves_like "an action guests and random logged-in users can't access",
                            attribute: attribute,
                            value: value
          end
        end

        { public: 1 }.each_pair do |attribute, value|
          context "with the #{attribute} param" do
            before do
              allow_any_instance_of(Skin).to receive(:valid_public_preview).and_return(true)
            end

            it_behaves_like "an attribute skin authors with the official role can update",
                            attribute: attribute,
                            value: value

            it_behaves_like "a skin admins can't update",
                            attribute: attribute,
                            value: value

            it_behaves_like "an action guests and random logged-in users can't access",
                            attribute: attribute,
                            value: value
          end
        end
      end
    end

    context "with a work skin" do
      context "when the skin is public" do
        let(:skin) { create(:work_skin, :public) }

        {
          title: "Edited title",
          css: "#workskin .new {\n  content: none;\n}\n\n",
          description: "<p>Updated version.</p>",
          role: "override",
          ie_condition: Skin::IE_CONDITIONS.last,
          unusable: 1,
          font: "Helvetica",
          base_em: 80,
          margin: 15,
          paragraph_margin: 1.5,
          background_color: "white",
          foreground_color: "black",
          headercolor: "#900",
          accent_color: "#EEEEEE"
        }.each_pair do |attribute, value|
          context "with the #{attribute} param" do
            it_behaves_like "an attribute authorized admins can update",
                            authorized_roles: manage_work_skin_roles,
                            attribute: attribute,
                            value: value

            it_behaves_like "a skin that skin authors can no longer update",
                            attribute: attribute,
                            value: value

            it_behaves_like "an action guests and random logged-in users can't access",
                            attribute: attribute,
                            value: value
          end
        end

        { public: 0 }.each_pair do |attribute, value|
          context "with the #{attribute} param" do
            before do
              allow_any_instance_of(Skin).to receive(:valid_public_preview).and_return(true)
            end

            it_behaves_like "a skin that skin authors can no longer update",
                            attribute: attribute,
                            value: value

            it_behaves_like "an attribute authorized admins can't update",
                            authorized_roles: manage_work_skin_roles,
                            attribute: attribute,
                            value: value

            it_behaves_like "an action guests and random logged-in users can't access",
                            attribute: attribute,
                            value: value
          end
        end
      end

      context "when the skin is not public" do
        let(:skin) { create(:work_skin) }

        {
          title: "Edited title",
          css: "#workskin .new {\n  content: none;\n}\n\n",
          description: "<p>Updated version.</p>",
          role: "override",
          ie_condition: Skin::IE_CONDITIONS.last,
          unusable: 1,
          font: "Helvetica",
          base_em: 80,
          margin: 15,
          paragraph_margin: 1.5,
          background_color: "white",
          foreground_color: "black",
          headercolor: "#900",
          accent_color: "#EEEEEE"
        }.each_pair do |attribute, value|
          context "with the #{attribute} param" do
            it_behaves_like "an attribute skin authors can update",
                            attribute: attribute,
                            value: value

            it_behaves_like "a skin admins can't update",
                            attribute: attribute,
                            value: value

            it_behaves_like "an action guests and random logged-in users can't access",
                            attribute: attribute,
                            value: value
          end
        end

        { public: 1 }.each_pair do |attribute, value|
          context "with the #{attribute} param" do
            before { allow_any_instance_of(Skin).to receive(:valid_public_preview).and_return(true) }

            it_behaves_like "an attribute skin authors with the official role can update",
                            attribute: attribute,
                            value: value

            it_behaves_like "a skin admins can't update",
                            attribute: attribute,
                            value: value

            it_behaves_like "an action guests and random logged-in users can't access",
                            attribute: attribute,
                            value: value
          end
        end
      end
    end
  end

  describe "POST #set" do
    shared_examples "user cannot set it" do
      it "redirects with an error about caching" do
        post :set, params: { id: skin.id }
        it_redirects_to_with_error(skin_path(skin), "Sorry, but only certain skins can be used this way (for performance reasons). Please drop a support request if you'd like Uncached Public Skin to be added!")
      end
    end

    shared_examples "user can set it" do
      it "redirects with success notice" do
        post :set, params: { id: skin.id }
        it_redirects_to_with_notice(skin_path(skin), "The skin Cached Public Skin has been set. This will last for your current session.")
      end
    end

    context "with an uncached site skin" do
      let(:skin) { create(:skin, :public, title: "Uncached Public Skin") }

      context "when logged in as a registered user" do
        before { fake_login }
        it_behaves_like "user cannot set it"
      end

      context "when admin has no role" do
        it_behaves_like "user cannot set it"
      end

      Admin::VALID_ROLES.each do |role|
        context "when admin has #{role} role" do
          let(:admin) { create(:admin, roles: [role]) }

          it_behaves_like "user cannot set it"
        end
      end
    end

    context "with a cached site skin" do
      let(:skin) { create(:skin, :public, title: "Cached Public Skin", cached: true) }

      context "when logged in as a registered user" do
        before { fake_login }
        it_behaves_like "user can set it"
      end

      context "when admin has no role" do
        it_behaves_like "user can set it"
      end

      Admin::VALID_ROLES.each do |role|
        context "when admin has #{role} role" do
          let(:admin) { create(:admin, roles: [role]) }

          it_behaves_like "user can set it"
        end
      end
    end
  end
end
