require "spec_helper"

describe OrphansController do
  include LoginMacros
  include RedirectExpectationHelper

  # Make sure that we have an orphan account:
  before { create(:user, login: "orphan_account") }

  let!(:user) { create(:user) }
  let!(:pseud) { create(:pseud, user: user) }
  let!(:work) { create(:work, authors: [pseud]) }
  let(:second_work) { create(:work, authors: user.pseuds) }
  let(:series) { create(:series, works: [work], authors: [pseud]) }

  let!(:suspended_user) { create(:user, suspended: true, suspended_until: 1.week.from_now) }
  let!(:suspended_pseud) { create(:pseud, user: suspended_user) }
  let!(:suspended_second_pseud) { create(:pseud, user: suspended_user) }
  let!(:suspended_users_work) do
    suspended_user.update!(suspended: false, suspended_until: nil)
    work = create(:work, authors: [suspended_pseud])
    suspended_user.update!(suspended: true, suspended_until: 1.week.from_now)
    work
  end
  let!(:suspended_users_second_work) do
    suspended_user.update!(suspended: false, suspended_until: nil)
    work = create(:work, authors: suspended_user.pseuds)
    suspended_user.update!(suspended: true, suspended_until: 1.week.from_now)
    work
  end
  let(:suspended_users_series) do
    suspended_user.update!(suspended: false, suspended_until: nil)
    series = create(:series, works: [work], authors: [suspended_pseud])
    suspended_user.update!(suspended: true, suspended_until: 1.week.from_now)
    series
  end

  let!(:banned_user) { create(:user, banned: true) }
  let!(:banned_pseud) { create(:pseud, user: banned_user) }
  let!(:banned_second_pseud) { create(:pseud, user: banned_user) }
  let!(:banned_users_work) do
    banned_user.update!(banned: false)
    work = create(:work, authors: [banned_pseud])
    banned_user.update!(banned: true)
    work
  end
  let!(:banned_users_second_work) do
    banned_user.update!(banned: false)
    work = create(:work, authors: banned_user.pseuds)
    banned_user.update!(banned: true)
    work
  end
  let(:banned_users_series) do
    banned_user.update!(banned: false)
    series = create(:series, works: [work], authors: [banned_pseud])
    banned_user.update!(banned: true)
    series
  end

  let(:other_user) { create(:user) }
  let(:other_work) { create(:work, authors: [other_user.default_pseud]) }

  describe "GET #new" do
    render_views

    context "when logged in as the owner" do
      before { fake_login_known_user(user.reload) }

      it "shows the form for orphaning a work" do
        get :new, params: { work_id: work }
        expect(response).to render_template(partial: "orphans/_orphan_work")
      end

      it "shows the form for orphaning multiple works" do
        get :new, params: { work_ids: [work, second_work] }
        expect(response).to render_template(partial: "orphans/_orphan_work")
      end

      it "shows the form for orphaning a series" do
        get :new, params: { series_id: series }
        expect(response).to render_template(partial: "orphans/_orphan_series")
      end

      it "shows the form for orphaning a pseud" do
        get :new, params: { pseud_id: pseud.id }
        expect(response).to render_template(partial: "orphans/_orphan_pseud")
      end

      it "shows the form for orphaning all your works" do
        get :new, params: {}
        expect(response).to render_template(partial: "orphans/_orphan_user")
      end
    end

    context "when logged in as a suspended user" do
      before { fake_login_known_user(suspended_user.reload) }
      
      it "errors and redirects to user page" do
        get :new, params: { work_id: suspended_users_work }
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end

      it "errors and redirects to user page" do
        get :new, params: { work_ids: [suspended_users_work, suspended_users_second_work] }
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end

      it "errors and redirects to user page" do
        get :new, params: { series_id: suspended_users_series }
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end

      it "errors and redirects to user page" do
        get :new, params: { pseud_id: suspended_user.pseuds.first }
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end

      it "errors and redirects to user page" do
        get :new, params: {}
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end
    end

    context "when logged in as a banned user" do
      before { fake_login_known_user(banned_user.reload) }
      
      it "shows the form for orphaning a work" do
        get :new, params: { work_id: banned_users_work }
        expect(response).to render_template(partial: "orphans/_orphan_work")
      end

      it "shows the form for orphaning multiple works" do
        get :new, params: { work_ids: [banned_users_work, banned_users_second_work] }
        expect(response).to render_template(partial: "orphans/_orphan_work")
      end

      it "shows the form for orphaning a series" do
        get :new, params: { series_id: banned_users_series }
        expect(response).to render_template(partial: "orphans/_orphan_series")
      end

      it "shows the form for orphaning a pseud" do
        get :new, params: { pseud_id: banned_pseud.id }
        expect(response).to render_template(partial: "orphans/_orphan_pseud")
      end

      it "shows the form for orphaning all your works" do
        get :new, params: {}
        expect(response).to render_template(partial: "orphans/_orphan_user")
      end
    end

    context "when logged in as another user" do
      before { fake_login_known_user(other_user.reload) }

      it "orphaning someone else's work shows an error and redirects" do
        get :new, params: { work_id: work }
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end

      it "orphaning multiple works by someone else shows an error and redirects" do
        get :new, params: { work_ids: [work, second_work] }
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end

      it "orphaning a mix of owned and un-owned works shows an error and redirects" do
        get :new, params: { work_ids: [work, other_work] }
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end

      it "orphaning someone else's series shows an error and redirects" do
        get :new, params: { series_id: series }
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end

      it "orphaning someone else's pseud shows an error and redirects" do
        get :new, params: { pseud_id: pseud.id }
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end
    end
  end

  describe "POST #create" do
    context "when logged in as the owner" do
      before { fake_login_known_user(user.reload) }

      it "successfully orphans a single work and redirects" do
        post :create, params: { work_ids: [work], use_default: "true" }
        expect(work.reload.users).not_to include(user)
        it_redirects_to_with_notice(user_path(user), "Orphaning was successful.")

        expect(work.original_creators.map(&:user_id)).to contain_exactly(user.id)
      end

      it "successfully orphans multiple works and redirects" do
        post :create, params: { work_ids: [work, second_work], use_default: "true" }
        expect(work.reload.users).not_to include(user)
        expect(second_work.reload.users).not_to include(user)
        it_redirects_to_with_notice(user_path(user), "Orphaning was successful.")

        expect(work.original_creators.map(&:user_id)).to contain_exactly(user.id)
        expect(second_work.original_creators.map(&:user_id)).to contain_exactly(user.id)
      end

      context "when a work has multiple pseuds for the same user" do
        let(:second_pseud) { create(:pseud, user: user) }
        let(:work) { create(:work, authors: [pseud, second_pseud]) }

        it "only saves the original creator once" do
          post :create, params: { work_ids: [work], use_default: "true" }
          expect(work.reload.users).not_to include(user)

          expect(work.original_creators.map(&:user_id)).to contain_exactly(user.id)
        end
      end

      it "successfully orphans a series and redirects" do
        post :create, params: { series_id: series, use_default: "true" }
        expect(series.reload.users).not_to include(user)
        it_redirects_to_with_notice(user_path(user), "Orphaning was successful.")
      end

      it "successfully orphans a pseud and redirects" do
        post :create, params: { work_ids: pseud.works.pluck(:id),
                                pseud_id: pseud.id, use_default: "true" }
        expect(work.reload.users).not_to include(user)
        it_redirects_to_with_notice(user_path(user), "Orphaning was successful.")
      end

      it "errors and redirects if you don't specify any works or series" do
        post :create, params: { pseud_id: pseud.id, use_default: "true" }
        it_redirects_to_with_error(user_path(user), "What did you want to orphan?")
      end
    end

    context "when logged in as a suspended user" do
      before { fake_login_known_user(suspended_user.reload) }

      it "errors and redirects to user page" do
        post :create, params: { work_ids: [suspended_users_work], use_default: "true" }
        expect(suspended_users_work.reload.users).to include(suspended_user)
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end

      it "errors and redirects to user page" do
        post :create, params: { work_ids: [suspended_users_work, suspended_users_second_work], use_default: "true" }
        expect(suspended_users_work.reload.users).to include(suspended_user)
        expect(suspended_users_second_work.reload.users).to include(suspended_user)
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end

      context "when a work has multiple pseuds for the same user" do
        let(:second_pseud) { create(:pseud, user: suspended_user) }
        let(:work) do
          suspended_user.update!(suspended: false, suspended_until: nil)
          work = create(:work, authors: [suspended_pseud, suspended_second_pseud])
          suspended_user.update!(suspended: true, suspended_until: 1.week.from_now)
          work
        end

        it "errors and redirects to user page" do
          post :create, params: { work_ids: [suspended_users_work], use_default: "true" }
          it_redirects_to_simple(user_path(suspended_user))
          expect(flash[:error]).to include("Your account has been suspended")
        end
      end

      it "errors and redirects to user page" do
        post :create, params: { series_id: suspended_users_series, use_default: "true" }
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end

      it "errors and redirects to user page" do
        post :create, params: { work_ids: suspended_pseud.works.pluck(:id),
                                pseud_id: suspended_pseud.id, use_default: "true" }
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end

      it "errors and redirects to user page" do
        post :create, params: { pseud_id: suspended_pseud.id, use_default: "true" }
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end
    end

    context "when logged in as a banned user" do
      before { fake_login_known_user(banned_user.reload) }

      it "successfully orphans a single work and redirects" do
        post :create, params: { work_ids: [banned_users_work], use_default: "true" }
        expect(banned_users_work.reload.users).not_to include(banned_user)
        it_redirects_to_with_notice(user_path(banned_user), "Orphaning was successful.")

        expect(banned_users_work.original_creators.map(&:user_id)).to contain_exactly(banned_user.id)
      end

      it "successfully orphans multiple works and redirects" do
        post :create, params: { work_ids: [banned_users_work, banned_users_second_work], use_default: "true" }
        expect(banned_users_work.reload.users).not_to include(banned_user)
        expect(banned_users_second_work.reload.users).not_to include(banned_user)
        it_redirects_to_with_notice(user_path(banned_user), "Orphaning was successful.")

        expect(banned_users_work.original_creators.map(&:user_id)).to contain_exactly(banned_user.id)
        expect(banned_users_second_work.original_creators.map(&:user_id)).to contain_exactly(banned_user.id)
      end

      context "when a work has multiple pseuds for the same user" do
        let(:second_pseud) { create(:pseud, user: banned_user) }
        let(:work) do
          banned_user.update!(banned: false)
          work = create(:work, authors: [banned_pseud, banned_second_pseud])
          banned_user.update!(banned: true)
          work
        end

        it "only saves the original creator once" do
          post :create, params: { work_ids: [banned_users_work], use_default: "true" }
          expect(banned_users_work.reload.users).not_to include(banned_user)

          expect(banned_users_work.original_creators.map(&:user_id)).to contain_exactly(banned_user.id)
        end
      end

      it "successfully orphans a series and redirects" do
        post :create, params: { series_id: banned_users_series, use_default: "true" }
        expect(banned_users_series.reload.users).not_to include(banned_user)
        it_redirects_to_with_notice(user_path(banned_user), "Orphaning was successful.")
      end

      it "successfully orphans a pseud and redirects" do
        post :create, params: { work_ids: banned_pseud.works.pluck(:id),
                                pseud_id: banned_pseud.id, use_default: "true" }
        expect(banned_users_work.reload.users).not_to include(banned_user)
        it_redirects_to_with_notice(user_path(banned_user), "Orphaning was successful.")
      end

      it "errors and redirects if you don't specify any works or series" do
        post :create, params: { pseud_id: banned_pseud.id, use_default: "true" }
        it_redirects_to_with_error(user_path(banned_user), "What did you want to orphan?")
      end
    end

    context "when logged in as another user" do
      before { fake_login_known_user(other_user.reload) }

      it "orphaning someone else's work shows an error and redirects" do
        post :create, params: { work_ids: [work], use_default: "true" }
        expect(work.reload.users).to include(user)
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end

      it "orphaning multiple works by someone else shows an error and redirects" do
        post :create, params: { work_ids: [work, second_work], use_default: "true" }
        expect(work.reload.users).to include(user)
        expect(second_work.reload.users).to include(user)
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end

      it "orphaning a mix of owned and un-owned works shows an error and redirects" do
        post :create, params: { work_ids: [work, other_work], use_default: "true" }
        expect(work.reload.users).to include(user)
        expect(other_work.reload.users).to include(other_user)
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end

      it "orphaning someone else's series shows an error and redirects" do
        post :create, params: { series_id: series, use_default: "true" }
        expect(series.reload.users).to include(user)
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end

      it "orphaning your own work with someone else's pseud shows an error and redirects" do
        post :create, params: { work_ids: [other_work],
                                pseud_id: pseud.id,
                                use_default: "true" }
        expect(work.reload.users).to include(user)
        expect(other_work.reload.users).to include(other_user)
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end

      it "orphaning someone else's work with your own pseud shows an error and redirects" do
        post :create, params: { work_ids: [work],
                                pseud_id: other_user.default_pseud_id,
                                use_default: "true" }
        expect(work.reload.users).to include(user)
        expect(other_work.reload.users).to include(other_user)
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end

      it "orphaning someone else's work with someone else's pseud shows an error and redirects" do
        post :create, params: { work_ids: [work],
                                pseud_id: pseud.id,
                                use_default: "true" }
        expect(work.reload.users).to include(user)
        expect(other_work.reload.users).to include(other_user)
        it_redirects_to_with_error(root_path, "You don't have permission to orphan that!")
      end
    end
  end
end
