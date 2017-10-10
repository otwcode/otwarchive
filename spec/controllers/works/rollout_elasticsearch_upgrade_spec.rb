# ES UPGRADE TRANSITION #
# Remove file
require "spec_helper"

describe WorksController do
  include LoginMacros

  describe "#use_new_search?" do

    before(:each) do
      unless elasticsearch_enabled?($elasticsearch)
        $rollout.deactivate(:use_new_search)
      end
    end

    after(:each) do
      unless elasticsearch_enabled?($elasticsearch)
        $rollout.activate(:use_new_search)
      end
    end

    it "should return false if there is no current user" do
      allow(controller).to receive(:current_user).and_return(nil)
      expect(controller.use_new_search?).to eq(false)
    end

    it "should return false if the current user is not activated for the use new search feature" do
      user = FactoryGirl.create(:user)
      fake_login_known_user(user)

      expect(controller.use_new_search?).to eq(false)
    end

    it "should return true if the current user is activated for the use new search feature" do
      user = FactoryGirl.create(:user)
      $rollout.activate_user(:use_new_search, user)
      fake_login_known_user(user)

      expect(controller.use_new_search?).to eq(true)
      $rollout.deactivate_user(:use_new_search, user)
    end

    it "should return true if use new search is activated globally" do
      $rollout.activate(:use_new_search)

      expect(controller.use_new_search?).to eq(true)

      $rollout.deactivate(:use_new_search)
    end
  end

  describe "#search" do
    it "should use the new work search form object when use_new_search? is true" do
      controller.stub(:use_new_search?) { true }
      expect(WorkSearchForm).to receive(:new)
      expect(WorkSearch).not_to receive(:new)
      get :search
    end

    it "should use the old work search object when use_new_search? is false" do
      controller.stub(:use_new_search?) { false }
      expect(WorkSearch).to receive(:new)
      expect(WorkSearchForm).not_to receive(:new)
      get :search
    end
  end

  describe "#index" do
    let(:user) { create(:user) }

    it "should use the new work search form object when use_new_search? is true" do
      controller.stub(:use_new_search?) { true }
      WorkSearchForm.any_instance.stub(:search_results) { OpenStruct.new(facets: []) }
      expect(WorkSearchForm).to receive(:new).and_return(WorkSearchForm.new({}))
      expect(WorkSearch).not_to receive(:new)
      get :index, params: { user_id: user.login }
    end

    it "should use the old work search object when use_new_search? is false" do
      controller.stub(:use_new_search?) { false }
      WorkSearch.any_instance.stub(:search_results) { OpenStruct.new(facets: []) }
      expect(WorkSearch).to receive(:new).and_return(WorkSearch.new({}))
      expect(WorkSearchForm).not_to receive(:new)
      get :index, params: { user_id: user.login }
    end
  end

  describe "#collected" do
    let(:user) { create(:user) }

    it "should use the new work search form object when use_new_search? is true" do
      controller.stub(:use_new_search?) { true }
      WorkSearchForm.any_instance.stub(:search_results) { OpenStruct.new(facets: []) }
      expect(WorkSearchForm).to receive(:new).and_return(WorkSearchForm.new({}))
      expect(WorkSearch).not_to receive(:new)
      get :collected, params: { user_id: user.login }
    end

    it "should use the old work search object when use_new_search? is false" do
      controller.stub(:use_new_search?) { false }
      WorkSearch.any_instance.stub(:search_results) { OpenStruct.new(facets: []) }
      expect(WorkSearch).to receive(:new).and_return(WorkSearch.new({}))
      expect(WorkSearchForm).not_to receive(:new)
      get :collected, params: { user_id: user.login }
    end
  end

end
