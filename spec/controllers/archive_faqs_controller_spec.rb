# frozen_string_literal: true

require "spec_helper"

describe ArchiveFaqsController do
  describe "GET #show" do
    it "raises a 404 for an invalid id" do
      params = { id: "angst", language_id: "en" }
      expect { get :show, params: params }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
