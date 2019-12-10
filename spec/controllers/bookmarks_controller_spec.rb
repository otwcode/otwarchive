require 'spec_helper'

describe BookmarksController do
  include LoginMacros
  include RedirectExpectationHelper

  def it_redirects_to_user_login
    it_redirects_to_simple new_user_session_path
  end

  describe 'new' do
    context 'without javascript' do
      it 'should not return the form for anyone not logged in' do
        get :new
        it_redirects_to_user_login
      end

      it 'should render the form if logged in' do
        fake_login
        get :new
        expect(response).to render_template('new')
      end
    end

    context 'with javascript' do
      it 'should render the bookmark_form_dynamic form if logged in' do
        fake_login
        get :new, params: { format: :js }, xhr: true
        expect(response).to render_template('bookmark_form_dynamic')
      end
    end
  end

  describe 'edit' do
    context 'with javascript' do
      let(:bookmark) { FactoryBot.create(:bookmark) }

      it 'should render the bookmark_form_dynamic form' do
        fake_login_known_user(bookmark.pseud.user)
        get :edit, params: { id: bookmark.id, format: :js }, xhr: true
        expect(response).to render_template('bookmark_form_dynamic')
      end
    end
  end
end
