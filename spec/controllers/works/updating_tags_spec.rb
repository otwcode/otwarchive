require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "POST #update_tags" do
    let(:work) { create(:work) }
    let!(:language) { create(:language) }

    shared_examples "can update work tags and language" do
      it "updates the work and redirects with notice" do
        post :update_tags, params: {
          id: work, work: { relationship_string: "kronfaumei", language_id: language.id }
        }
        it_redirects_to_with_notice(work_path(work), "Work was successfully updated.")
        expect(work.reload.relationship_string).to eq("kronfaumei")
        expect(work.language).to eq(language)
      end
    end

    context "when logged in as the work creator" do
      before { fake_login_known_user(work.users.first) }

      it_behaves_like "can update work tags and language"
    end
  end
end
