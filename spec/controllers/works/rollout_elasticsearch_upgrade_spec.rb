require "spec_helper"

describe WorksController do
  include LoginMacros

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
