require 'spec_helper'

describe SeriesController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }
  let(:series) { create(:series, authors: [user.default_pseud]) }

  describe 'new' do
    it 'assigns a series' do
      get :new
      expect(assigns(:series)).to be_a_new(Series)
    end
  end

  describe 'edit' do
    it 'redirects to orphan if there are no pseuds left' do
      fake_login_known_user(user)
      get :edit, params: { remove: "me", id: series }
      it_redirects_to(new_orphan_path(series_id: series))
    end
  end

  describe 'create' do
    it 'renders new if the series is invalid' do
      fake_login_known_user(user)
      post :create, params: { series: {summary: ""} }
      expect(response).to render_template('new')
    end

    it 'gives notice and redirects on a valid series' do
      fake_login_known_user(user)
      post :create, params: { series: { title: "test title", author_attributes: { ids: user.pseud_ids } } }
      expect(flash[:notice]).to eq "Series was successfully created."
      expect(response).to have_http_status :redirect
    end
  end

  describe 'update' do
    it "redirects and errors if removing the last author of a series" do
      fake_login_known_user(user)
      put :update, params: { series: { author_attributes: { ids: [""] } }, id: series }
      expect(response).to render_template :edit
      expect(assigns[:series].errors.full_messages).to \
        include "You haven't selected any pseuds for this series."
    end

    it "allows you to change which of your pseuds is listed on the series" do
      fake_login_known_user(user)
      new_pseud = create(:pseud, user: user)
      put :update, params: { series: { author_attributes: { ids: [new_pseud.id] } }, id: series }
      it_redirects_to_with_notice(series_path(series), \
                                  "Series was successfully updated.")
      expect(series.pseuds.reload).to contain_exactly(new_pseud)
    end

    it "allows you to invite co-creators" do
      fake_login_known_user(user)
      co_creator = create(:user)
      co_creator.preference.update(allow_cocreator: true)
      put :update, params: { series: { author_attributes: { byline: co_creator.login } }, id: series }
      it_redirects_to_with_notice(series_path(series), \
                                  "Series was successfully updated.")
      expect(series.pseuds.reload).not_to include(co_creator.default_pseud)
      expect(series.user_has_creator_invite?(co_creator)).to be_truthy
    end

    it "renders the edit template if the update fails" do
      fake_login_known_user(user)
      allow_any_instance_of(Series).to receive(:save) { false }
      put :update, params: { series: { title: "foobar" }, id: series }
      expect(response).to render_template('edit')
      expect(series.reload.title).not_to eq("foobar")
    end
  end

  describe 'update_positions' do
    it 'updates the position and redirects' do
      fake_login_known_user(user)
      first_work = create(:serial_work, series: series)
      second_work = create(:serial_work, series: series)
      expect(first_work.position).to eq(1)
      expect(second_work.position).to eq(2)
      post :update_positions, params: { id: series.id, serial: [second_work, first_work], format: :json }
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
      delete :destroy, params: { id: series }
      it_redirects_to_with_error(series_path(series), \
                                 "Sorry, we couldn't delete the series. Please try again.")
    end
  end
end
