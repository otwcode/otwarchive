require 'spec_helper'

describe LanguagesController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:admin) { create(:admin) }

  describe 'GET index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET show' do
    it 'renders the show template' do
      get :show, params: { id: 'en' }
      expect(response).to render_template('show')
    end
  end

  describe 'GET new' do
    it 'renders the new template' do
      fake_login_admin(admin)
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST create' do
    before do
      fake_login_admin(admin)
      post :create, params: {
        language: {
          name: 'Suomi',
          short: 'fi',
          support_available: false,
          abuse_support_available: false,
          sortable_name: 'su'
        }
      }
    end

    it 'creates the new language' do
      new_lang = Language.last
      expect(new_lang.name).to eq('Suomi')
      expect(new_lang.short).to eq('fi')
      expect(new_lang.support_available).to eq(false)
      expect(new_lang.abuse_support_available).to eq(false)
      expect(new_lang.sortable_name).to eq('su')
    end

    it 'redirects to languages_path' do
      it_redirects_to(languages_path)
    end
  end

  describe 'GET edit' do
    it 'renders the edit template' do
      fake_login_admin(admin)
      get :edit, params: { id: 'en' }
      expect(response).to render_template('edit')
    end
  end

  describe 'PUT update' do
    let(:finnish) { Language.create(name: 'Suomi', short: 'fi') }

    before do
      fake_login_admin(admin)
      put :update, params: {
        id: finnish.short,
        language: {
          name: 'Suomi',
          short: 'fi',
          support_available: true,
          abuse_support_available: false,
          sortable_name: 'su'
        }
      }
    end

    it 'updates the language' do
      finnish.reload
      expect(finnish.name).to eq('Suomi')
      expect(finnish.short).to eq('fi')
      expect(finnish.support_available).to eq(true)
      expect(finnish.abuse_support_available).to eq(false)
      expect(finnish.sortable_name).to eq('su')
    end

    it 'redirects and returns success message' do
      it_redirects_to_with_notice(finnish, 'Language was successfully updated.')
    end
  end
end
