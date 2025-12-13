# frozen_string_literal: true

require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #new" do
    context "when collection is closed" do
      let(:collection) { create(:collection, title: "Excalibur", collection_preference: create(:collection_preference, closed: true)) }
      let(:user) { create(:user) }

      before { fake_login_known_user(user) }

      it "redirects to collection page with error for non-maintainers" do
        get :new, params: { collection_id: collection.name }
        it_redirects_to_with_error(collection_path(collection), "Sorry, the collection Excalibur is closed, new works cannot be added to it.")
      end
    end

    context "when collection is closed but user is owner" do
      let(:user) { create(:user) }
      let(:collection) { create(:collection, title: "Excalibur", collection_preference: create(:collection_preference, closed: true)) }

      before do
        fake_login_known_user(user)
        collection.collection_participants.create(pseud: user.default_pseud, participant_role: CollectionParticipant::OWNER)
      end

      it "allows access to new work form" do
        get :new, params: { collection_id: collection.name }
        expect(response).to render_template("new")
      end
    end

    context "when collection is closed but user is maintainer" do
      let(:user) { create(:user) }
      let(:collection) { create(:collection, title: "Excalibur", collection_preference: create(:collection_preference, closed: true)) }

      before do
        fake_login_known_user(user)
        collection.collection_participants.create(pseud: user.default_pseud, participant_role: CollectionParticipant::MODERATOR)
      end

      it "allows access to new work form" do
        get :new, params: { collection_id: collection.name }
        expect(response).to render_template("new")
      end
    end

    context "when collection is open" do
      let(:collection) { create(:collection, title: "Excalibur", collection_preference: create(:collection_preference, closed: false)) }
      let(:user) { create(:user) }

      before { fake_login_known_user(user) }

      it "allows access to new work form" do
        get :new, params: { collection_id: collection.name }
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET #navigate" do
    context "denies access for work that isn't visible to user" do
      subject { get :navigate, params: { id: work.id } }
      let(:success) { expect(response).to render_template("navigate") }
      let(:success_admin) { success }

      include_examples "denies access for work that isn't visible to user"
    end

    context "denies access for restricted work to guest" do
      let(:work) { create(:work, restricted: true) }

      it "redirects with an error" do
        get :navigate, params: { id: work.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end
  end
end
