require 'spec_helper'

RSpec.describe SeriesController, type: :controller do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }
  let(:series) { create(:series, pseuds: user.pseuds) }

  describe 'new' do
    it 'assigns a series' do
      get :new
      expect(assigns(:series)).to be_a_new(Series)
    end
  end

  describe 'edit' do
    it 'redirects to orphan if there are no pseuds left' do
      fake_login_known_user(user)
      get :edit, remove: "me", id: series
      it_redirects_to(new_orphan_path(series_id: series))
    end
  end

  describe 'create' do
    it 'renders new if the series is invalid' do
      fake_login_known_user(user)
      post :create, series: {summary: ""}
      expect(response).to render_template('new')
    end

    it 'gives notice and redirects on a valid series' do
      fake_login_known_user(user)
      post :create, series: { title: "test title" }
      expect(flash[:notice]).to eq "Series was successfully created."
      expect(response).to have_http_status :redirect
    end
  end

  describe 'update' do
    it 'redirects and errors if removing the last author of a series' do
      fake_login_known_user(user)
      put :update, series: { author_attributes: {} }, id: series
      it_redirects_to_with_error(edit_series_path(series), \
                                 "Sorry, you cannot remove yourself entirely as an author of a series right now.")
    end

    xit 'allows you to change the pseuds associated with the series' do
      fake_login_known_user(user)
      new_pseud = create(:pseud)
        put :update, series: { author_attributes: { ids: [user.id] } }, id: series, pseud: { byline: new_pseud.byline }
      it_redirects_to_with_notice(series_path(series), \
                                  "Series was successfully updated.")
      series.reload
      expect(series.pseuds).to include(new_pseud)
    end

    it 'renders the edit template if the update fails' do
      fake_login_known_user(user)
      new_pseud = create(:pseud)
      allow_any_instance_of(Series).to receive(:update_attributes) { false }
      put :update, series: { author_attributes: { ids: [user.id] } }, id: series, pseud: { byline: new_pseud.byline }
      expect(assigns(:pseuds))
      expect(assigns(:coauthors))
      expect(assigns(:selected_pseuds))
      expect(response).to render_template('edit')
    end
  end

  describe 'update_positions' do
    it 'updates the position and redirects' do
      fake_login_known_user(user)
      first_work = create(:serial_work, series: series)
      second_work = create(:serial_work, series: series)
      expect(first_work.position).to eq(1)
      expect(second_work.position).to eq(2)
      post :update_positions, serial: [second_work, first_work], format: :json
      first_work.reload
      second_work.reload
      expect(first_work.position).to eq(2)
      expect(second_work.position).to eq(1)
    end
  end

  describe 'destory' do
    it 'on an exception gives an error and redirects' do
      fake_login_known_user(user)
      allow_any_instance_of(Series).to receive(:destroy) { false }
      delete :destroy, id: series
      it_redirects_to_with_error(series_path(series), \
                                 "Sorry, we couldn't delete the series. Please try again.")
    end
  end
end
