require 'spec_helper'

describe TagSetNominationsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:tag_setter) { FactoryGirl.create(:user) }
  let(:tag_setter_pseud) { FactoryGirl.create(:pseud, user_id: tag_setter.id) }

  describe 'GET index' do

  end

  describe 'GET show' do
    let!(:tag_set_nomination) { FactoryGirl.create(:tag_set_nomination, pseud_id: tag_setter_pseud.id) }
    let(:owned_tag_set) { tag_set_nomination.owned_tag_set}

    context 'user is not logged in' do
      it 'redirects and shows an error message' do
        get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'user is logged in' do
      context 'invalid params' do
        before do
          fake_login_known_user(tag_setter)
        end

        # is testing this even possible?
        # how can OwnedTagSet.find not raise an error but still return falsey?
        xcontext 'no tag set' do
          it 'redirects and shows an error message' do
            get :show, id: tag_set_nomination.id, tag_set_id: nil
            it_redirects_to_with_error(tag_sets_path, "What tag set did you want to nominate for?")
          end
        end

        # is testing this even possible?
        # how can TagSetNomination.find not raise an error but still return falsey?
        xcontext 'no tag set nomination' do
          it 'redirects and shows an error message' do
            get :show, id: nil, tag_set_id: owned_tag_set.id
            it_redirects_to_with_error(user_tag_set_nominations_path(tag_setter), "Which nominations did you want to work with?")
          end
        end
      end

      context 'valid params' do
        context 'logged in user is not author of nomination' do
          let(:moderator) { FactoryGirl.create(:user) }
          let(:mod_pseud) { FactoryGirl.create(:pseud, user_id: moderator.id) }

          before do
            owned_tag_set.add_moderator(mod_pseud)
            owned_tag_set.save!
            moderator.reload
          end

          context 'user is not moderator of tag set' do
            before do
              random_user = FactoryGirl.create(:user)
              fake_login_known_user(random_user)
            end

            it 'redirects and shows an error message' do
              get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              it_redirects_to_with_notice(tag_set_path(owned_tag_set),
                                         "You can only see your own nominations or nominations for a set you moderate.")
            end
          end

          context 'user is moderator of tag set' do
            before do
              fake_login_known_user(moderator)
            end

            it 'renders the show template' do
              get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              expect(response).to render_template("show")
            end
          end
        end

        context 'logged in user is author of nomination' do
          before do
            fake_login_known_user(tag_setter)
          end

          context 'user is not moderator of tag set' do
            it 'renders the show template' do
              tag_setter.reload # Whywhywhywhy

              get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              expect(response).to render_template("show")
            end
          end

          context 'user is also moderator of tag set' do
            before do
              owned_tag_set.add_moderator(tag_setter_pseud)
              owned_tag_set.save!
              tag_setter.reload
            end

            it 'renders the show template' do
              get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              expect(response).to render_template("show")
            end
          end
        end
      end
    end
  end

  describe 'POST create' do

  end

  describe 'PUT update' do

  end

  describe 'DELETE destroy' do

  end

  describe 'PUT edit' do

  end

  describe 'GET confirm_destroy_multiple' do

  end

  describe 'DELETE destroy_multiple' do

  end

  describe 'PUT update_multiple' do

  end

  describe 'check_pseud_ownership'
  describe 'load_tag_set'
  describe 'load_nomination'
  describe 'set_limit'
  describe 'build_nominations'
  describe 'request_noncanonical_info'
  describe 'base_nom_query'
  describe 'setup_for_review'
end
