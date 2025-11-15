# frozen_string_literal: true

require "spec_helper"

describe SkinsController do
  include LoginMacros
  include RedirectExpectationHelper

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

  site_skin_edit_roles = %w[superadmin].freeze
  work_skin_edit_roles = %w[superadmin support].freeze

  describe "GET #edit" do
    subject { get :edit, params: { id: skin.id } }
    let(:success) do
      expect(response).to render_template(:edit)
    end

    context "with a site skin" do
      let(:skin) { create(:skin, :public) }

      it_behaves_like "an action only authorized admins can access", authorized_roles: site_skin_edit_roles
    end

    context "with a work skin" do
      let(:skin) { create(:work_skin, :public) }

      it_behaves_like "an action only authorized admins can access", authorized_roles: work_skin_edit_roles
    end
  end

  describe "PUT #update" do
    let(:skin_params) do
      {
        skin: {
          title: "Edited title"
        }
      }
    end
    let(:admin) { create(:admin) }

    before { fake_login_admin(admin) }

    shared_examples "unauthorized admin cannot update" do
      it "does not modify the skin" do
        expect do
          put :update, params: { id: skin.id }.merge(skin_params)
        end.not_to change { skin.reload.title }
      end
    end

    shared_examples "authorized admin can update" do
      it "modifies the skin" do
        expect do
          put :update, params: { id: skin.id }.merge(skin_params)
        end.to change { skin.reload.title }.to("Edited title")
      end
    end

    context "with a site skin" do
      let(:skin) { create(:skin, :public) }

      context "when admin has no role" do
        it_behaves_like "unauthorized admin cannot update"
      end

      (Admin::VALID_ROLES - %w[superadmin]).each do |role|
        context "when admin has #{role} role" do
          let(:admin) { create(:admin, roles: [role]) }

          it_behaves_like "unauthorized admin cannot update"
        end
      end

      context "when admin has superadmin role" do
        let(:admin) { create(:admin, roles: ["superadmin"]) }

        it_behaves_like "authorized admin can update"
      end
    end

    context "with a work skin" do
      let(:skin) { create(:work_skin, :public) }

      context "when admin has no role" do
        it_behaves_like "unauthorized admin cannot update"
      end

      (Admin::VALID_ROLES - %w[superadmin support]).each do |role|
        context "when admin has #{role} role" do
          let(:admin) { create(:admin, roles: [role]) }

          it_behaves_like "unauthorized admin cannot update"
        end
      end

      %w[superadmin support].each do |role|
        context "when admin has #{role} role" do
          let(:admin) { create(:admin, roles: [role]) }

          it_behaves_like "authorized admin can update"
        end
      end
    end
  end

  describe "POST #set" do
    let(:admin) { create(:admin) }

    before { fake_login_admin(admin) }

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
