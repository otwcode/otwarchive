# frozen_string_literal: true
require "spec_helper"

describe TroubleshootingController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:tag) { create(:canonical_fandom) }
  let(:work) { create(:work) }
  let(:tag_wrangler) { create(:user, roles: [Role.new(name: "tag_wrangler")]) }
  let(:non_tag_wrangler) { create(:user) }

  context "show" do
    context "when logged out" do
      it "errors and redirects to the login page" do
        get :show, params: { tag_id: tag.to_param }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when logged in as a regular user" do
      before { fake_login_known_user(non_tag_wrangler) }

      it "errors and redirects to user's profile" do
        get :show, params: { tag_id: tag.to_param }
        it_redirects_to_with_error(non_tag_wrangler, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged in as a tag wrangler" do
      before { fake_login_known_user(tag_wrangler) }

      it "shows a form with the allowed actions for tags" do
        get :show, params: { tag_id: tag.to_param }
        expect(response).to render_template(:show)
        expect(assigns[:allowed_actions]).to \
          contain_exactly(*%w[fix_counts])
      end

      it "shows a form with the allowed actions for works" do
        get :show, params: { work_id: work.id }
        expect(response).to render_template(:show)
        expect(assigns[:allowed_actions]).to \
          contain_exactly(*%w[reindex_work update_work_filters])
      end
    end

    context "when logged in as an admin" do
      before { fake_login_admin(create(:admin)) }

      it "shows a form with the allowed actions for tags" do
        get :show, params: { tag_id: tag.to_param }
        expect(response).to render_template(:show)
        expect(assigns[:allowed_actions]).to \
          contain_exactly(*%w[reindex_tag update_tag_filters fix_counts])
      end

      it "shows a form with the allowed actions for works" do
        get :show, params: { work_id: work.id }
        expect(response).to render_template(:show)
        expect(assigns[:allowed_actions]).to \
          contain_exactly(*%w[reindex_work update_work_filters])
      end
    end
  end

  context "update" do
    context "when logged out" do
      it "errors and redirects to the login page" do
        put :update, params: { tag_id: tag.to_param, actions: ["fix_counts"] }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when logged in as a regular user" do
      before { fake_login_known_user(non_tag_wrangler) }

      it "errors and redirects to user's profile" do
        put :update, params: { tag_id: tag.to_param, actions: ["fix_counts"] }
        it_redirects_to_with_error(non_tag_wrangler, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged in as a tag wrangler" do
      before { fake_login_known_user(tag_wrangler) }

      it "fixes tag counts and redirects to the tag" do
        tag.create_filter_count(public_works_count: 100)

        expect(tag.filter_count.public_works_count).to eq 100
        put :update, params: { tag_id: tag.to_param, actions: ["fix_counts"] }

        tag.reload
        expect(tag.filter_count.public_works_count).to eq 0
        it_redirects_to_simple(tag_path(tag))
      end

      it "doesn't allow the user to reindex a tag" do
        put :update, params: { tag_id: tag.to_param, actions: ["reindex_tag"] }
        it_redirects_to_with_error(tag_troubleshooting_path(tag), "The following actions aren't allowed: reindex_tag.")
      end

      it "doesn't allow the user to update filters for a tag" do
        put :update, params: { tag_id: tag.to_param, actions: ["update_tag_filters"] }
        it_redirects_to_with_error(tag_troubleshooting_path(tag), "The following actions aren't allowed: update_tag_filters.")
      end

      it "reindexes the work and redirects" do
        expect do
          put :update, params: { work_id: work.id, actions: ["reindex_work"] }
        end.to(add_to_reindex_queue(work, :main))
        it_redirects_to_simple(work)
      end

      it "recalculates the work's filters and redirects" do
        tag_work = create(:work, fandoms: [tag])
        tag_work.filter_taggings.destroy_all

        put :update, params: { work_id: tag_work.id, actions: ["update_work_filters"] }

        expect(tag_work.filters.reload).to include(tag)
        it_redirects_to_simple(tag_work)
      end
    end

    context "when logged in as an admin" do
      before { fake_login_admin(create(:admin)) }

      it "fixes tag counts and redirects to the tag" do
        tag.create_filter_count(public_works_count: 100)

        expect(tag.filter_count.public_works_count).to eq 100
        put :update, params: { tag_id: tag.to_param, actions: ["fix_counts"] }

        tag.reload
        expect(tag.filter_count.public_works_count).to eq 0
        it_redirects_to_simple(tag_path(tag))
      end

      it "reindexes everything related to the tag and redirects" do
        bookmark = create(:bookmark, tags: [tag])
        series = create(:series)
        work = create(:work, fandoms: [tag], series: [series])
        external_work = create(:external_work, fandoms: [tag])
        pseud = work.pseuds.first

        expect do
          put :update, params: { tag_id: tag.to_param, actions: ["reindex_tag"] }
        end.to(
          add_to_reindex_queue(series, :background) &
          add_to_reindex_queue(bookmark, :background) &
          add_to_reindex_queue(work, :background) &
          add_to_reindex_queue(pseud, :background) &
          add_to_reindex_queue(external_work, :background)
        )

        it_redirects_to_simple(tag_path(tag))
      end

      it "recalculates filters and redirects to the tag" do
        syn = create(:fandom, merger: tag)
        tag_work = create(:work, fandoms: [tag])
        tag_work.filter_taggings.destroy_all
        syn_work = create(:work, fandoms: [syn])
        syn_work.filter_taggings.destroy_all

        put :update, params: { tag_id: tag.to_param, actions: ["update_tag_filters"] }

        expect(tag_work.filters.reload).to include(tag)
        expect(syn_work.filters.reload).to include(tag)
        it_redirects_to_simple(tag_path(tag))
      end

      it "reindexes the work and redirects" do
        expect do
          put :update, params: { work_id: work.id, actions: ["reindex_work"] }
        end.to(add_to_reindex_queue(work, :main))
        it_redirects_to_simple(work)
      end

      it "recalculates the work's filters and redirects" do
        tag_work = create(:work, fandoms: [tag])
        tag_work.filter_taggings.destroy_all

        put :update, params: { work_id: tag_work.id, actions: ["update_work_filters"] }

        expect(tag_work.filters.reload).to include(tag)
        it_redirects_to_simple(tag_work)
      end
    end
  end
end
