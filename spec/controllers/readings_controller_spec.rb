require "spec_helper"

describe ReadingsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }

  describe "GET #index" do
    context "with user params" do
      context "when logged in as admin" do
        it "redirects to login page with error" do
          fake_login_admin(create(:admin))
          get :index, params: { user_id: user }
          it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        end
      end

      context "when logged out" do
        it "redirects to login page with error" do
          get :index, params: { user_id: user }
          it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        end
      end

      context "when logged in as another user" do
        it "redirects to requested user's dashboard with error" do
          fake_login
          get :index, params: { user_id: user }
          it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
        end
      end

      context "when logged in as the user" do
        it "includes user's readings sorted by last_viewed" do
          reading1 = create(:reading, user: user, last_viewed: 2.days.ago)
          reading2 = create(:reading, user: user, last_viewed: 1.hour.ago)
          reading3 = create(:reading, user: user, last_viewed: 5.hours.ago)
          reading4 = create(:reading)

          fake_login_known_user(user)
          get :index, params: { user_id: user }
          expect(assigns(:readings)).to eq([reading2, reading3, reading1])
          expect(assigns(:readings)).not_to include(reading4)
        end

        it "includes user's readings for restricted works" do
          work = create(:work, restricted: true)
          reading1 = create(:reading, user: user, work: work)
          reading2 = create(:reading, work: work)

          fake_login_known_user(user)
          get :index, params: { user_id: user }
          expect(assigns(:readings)).to include(reading1)
          expect(assigns(:readings)).not_to include(reading2)
        end

        it "includes user's readings for deleted works" do
          reading1 = create(:reading, :deleted_work, user: user)
          reading2 = create(:reading, :deleted_work)

          fake_login_known_user(user)
          get :index, params: { user_id: user }
          expect(assigns(:readings)).to include(reading1)
          expect(assigns(:readings)).not_to include(reading2)
        end

        it "excludes user's readings for hidden works" do
          work = create(:work, hidden_by_admin: true)
          reading1 = create(:reading, user: user, work: work)
          reading2 = create(:reading, work: work)

          fake_login_known_user(user)
          get :index, params: { user_id: user }
          expect(assigns(:readings)).not_to include(reading1)
          expect(assigns(:readings)).not_to include(reading2)
        end

        it "excludes user's readings for draft works" do
          work = create(:draft)
          reading1 = create(:reading, user: user, work: work)
          reading2 = create(:reading, work: work)

          fake_login_known_user(user)
          get :index, params: { user_id: user }
          expect(assigns(:readings)).not_to include(reading1)
          expect(assigns(:readings)).not_to include(reading2)
        end

        context "with show=to-read params" do
          it "includes user's toread readings sorted by last_viewed" do
            reading1 = create(:reading, user: user, last_viewed: 2.days.ago, toread: true)
            reading2 = create(:reading, user: user, last_viewed: 1.hour.ago, toread: true)
            reading3 = create(:reading, user: user, last_viewed: 12.hours.ago)
            reading4 = create(:reading, toread: true)

            fake_login_known_user(user)
            get :index, params: { user_id: user, show: "to-read" }
            expect(assigns(:readings)).to eq([reading2, reading1])
            expect(assigns(:readings)).not_to include(reading3)
            expect(assigns(:readings)).not_to include(reading4)
          end

          it "includes user's toread readings for restricted works" do
            work = create(:work, restricted: true)
            reading1 = create(:reading, user: user, work: work, toread: true)
            reading2 = create(:reading, work: work, toread: true)

            fake_login_known_user(user)
            get :index, params: { user_id: user, show: "to-read" }
            expect(assigns(:readings)).to include(reading1)
            expect(assigns(:readings)).not_to include(reading2)
          end

          it "includes user's toread readings for deleted works" do
            reading1 = create(:reading, :deleted_work, user: user, toread: true)
            reading2 = create(:reading, :deleted_work, toread: true)

            fake_login_known_user(user)
            get :index, params: { user_id: user, show: "to-read" }
            expect(assigns(:readings)).to include(reading1)
            expect(assigns(:readings)).not_to include(reading2)
          end

          it "excludes user's toread readings for hidden works" do
            work = create(:work, hidden_by_admin: true)
            reading1 = create(:reading, user: user, work: work, toread: true)
            reading2 = create(:reading, work: work, toread: true)

            fake_login_known_user(user)
            get :index, params: { user_id: user, show: "to-read" }
            expect(assigns(:readings)).not_to include(reading1)
            expect(assigns(:readings)).not_to include(reading2)
          end

          it "excludes user's toread readings for draft works" do
            work = create(:draft)
            reading1 = create(:reading, user: user, work: work, toread: true)
            reading2 = create(:reading, work: work, toread: true)

            fake_login_known_user(user)
            get :index, params: { user_id: user, show: "to-read" }
            expect(assigns(:readings)).not_to include(reading1)
            expect(assigns(:readings)).not_to include(reading2)
          end
        end
      end
    end
  end
end
