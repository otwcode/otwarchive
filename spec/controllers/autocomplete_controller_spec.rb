require 'spec_helper'

describe AutocompleteController do

  before do
    # clear out the test redis db so we don't get duplicate entries
    REDIS_GENERAL.flushdb
  end

  describe "do_tag" do
    it "should only return matching tags" do
      @tag = FactoryGirl.create(:fandom, name: "Match")
      @tag2 = FactoryGirl.create(:fandom, name: "Blargh")

      # we need to set this to make the controller return the JSON-encoded data we want
      @request.env['HTTP_ACCEPT'] = "application/json"
      get :tag, term: "Ma"
      expect(response.body).to include("Match")
      expect(response.body).not_to include("Blargh")
    end
  end

end