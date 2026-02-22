# frozen_string_literal: true

require "spec_helper"

describe GiftsController do
  include LoginMacros
  include RedirectExpectationHelper
  render_views

  describe "toggle_rejected" do
    let(:gift) { create(:gift) }

    it "errors and redirects to login page if no user is logged on" do
      post :toggle_rejected, params: { id: gift.id }
      it_redirects_to_user_login_with_error
    end

    it "errors and redirects to homepage if the gift's recipient is not logged on" do
      fake_login
      post :toggle_rejected, params: { id: gift.id }
      it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
    end
  end

  describe "index" do
    context "without user_id or recipient parameter" do
      it "redirects to the homepage with an error" do
        get :index
        it_redirects_to_with_error(root_path, "Whose gifts did you want to see?")
      end
    end

    context "with user_id parameter" do
      context "when user_id does not exist" do
        it "raises an error" do
          expect do
            get :index, params: { user_id: "nobody" }
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when viewing a user's gifts as an admin" do
        let(:gift_user) { create(:user) }
        let!(:accepted_work) { create(:work, title: "Accepted Gift Story") }
        let!(:refused_work) { create(:work, title: "Refused Gift Story") }
        let!(:accepted_gift) { create(:gift, pseud: gift_user.default_pseud, work: accepted_work) }
        let!(:refused_gift) { create(:gift, pseud: gift_user.default_pseud, work: refused_work, rejected: true) }

        before do
          allow(SearchCounts).to receive(:work_count_for_user).and_return(0)
          allow(SearchCounts).to receive(:bookmark_count_for_user).and_return(0)
          allow(SearchCounts).to receive(:collection_count_for_user).and_return(0)
        end

        %w[policy_and_abuse superadmin].each do |role|
          context "when admin has #{role} role" do
            before { fake_login_admin(create(:admin, roles: [role])) }

            it "shows refused gifts with navigation but without recipient action buttons" do
              get :index, params: { user_id: gift_user.login, refused: true }

              expect(assigns(:works)).to include(refused_work)
              expect(assigns(:works)).not_to include(accepted_work)
              expect(response.body).to include("Accepted Gifts")
              expect(response.body).to include("Refused Gifts")
              expect(response.body).to include("Refused Gifts for #{gift_user.login}")
              expect(response.body).not_to include("Refuse Gift")
              expect(response.body).not_to include("Accept Gift")
            end
          end
        end

        context "when admin does not have policy_and_abuse or superadmin role" do
          before { fake_login_admin(create(:support_admin)) }

          it "does not show refused gifts or navigation" do
            get :index, params: { user_id: gift_user.login, refused: true }

            expect(assigns(:works)).to include(accepted_work)
            expect(assigns(:works)).not_to include(refused_work)
            expect(response.body).not_to include("Accepted Gifts")
            expect(response.body).not_to include("Refused Gifts for #{gift_user.login}")
          end
        end
      end
    end
  end
end
