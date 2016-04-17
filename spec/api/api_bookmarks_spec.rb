require 'spec_helper'
require 'api/api_helper'

describe "API BookmarksController" do
  include ApiHelper

  # Override is_archivist so all users are archivists from this point on
  class User < ActiveRecord::Base
    def is_archivist?
      true
    end
  end

  external_work = {
    url: "http://foo.com",
    author: "Thing",
    title: "Title Thing",
    summary: "<p>blah blah blah</p>",
    fandom_string: "Testing",
    rating_string: "General Audiences",
    category_string: ["M/M"],
    relationship_string: "Starsky/Hutch",
    character_string: "Starsky,hutch"
  }

  bookmark = { pseud_id: "30805",
               external: external_work,
               notes: "<p>Notes</p>",
               tag_string: "youpi",
               collection_names: "",
               private: "0",
               rec: "0" }

  describe "API import with a valid archivist" do
    before do
      mock_external
      @user = create(:user)
    end

    after do
      WebMock.reset!
    end

    it "should return 200 OK when all bookmarks are created" do
      post "/api/v1/bookmarks/import",
           { archivist: @user.login,
             bookmarks: [ bookmark ]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
    end

    it "should return 200 OK when no bookmarks are created" do
      post "/api/v1/bookmarks/import",
           { archivist: @user.login,
             bookmarks: [ bookmark ]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
    end

    it "should return 200 OK when only some bookmarks are created" do
      post "/api/v1/bookmarks/import",
           { archivist: @user.login,
             bookmarks: [ bookmark, bookmark ]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
    end

    it "should create bookmarks associated with the archivist" do
      pseud_id = @user.default_pseud.id
      post "/api/v1/bookmarks/import",
           { archivist: @user.login,
             bookmarks: [ bookmark, bookmark ]
           }.to_json,
           valid_headers
      bookmarks = Bookmark.find_all_by_pseud_id(pseud_id)
      assert_equal bookmarks.count, 2
    end

    it "should return 400 Bad Request if an invalid URL is specified" do
      post "/api/v1/import",
           { archivist: @user.login,
             bookmarks: [ bookmark.merge!( { external: external_work.merge!( { url: "http://bar.com" })}) ] }.to_json,
           valid_headers
      assert_equal 400, response.status
    end

    it "should return 400 Bad Request if no bookmarks are specified" do
      post "/api/v1/import",
           { archivist: @user.login }.to_json,
           valid_headers
      assert_equal 400, response.status
    end
  end

  WebMock.allow_net_connect!
end
