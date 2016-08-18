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

  bookmark = { id: "123",
               url: "http://foo.com",
               author: "Thing",
               title: "Title Thing",
               summary: "<p>blah blah blah</p>",
               fandom_string: "Testing",
               rating_string: "General Audiences",
               category_string: ["M/M"],
               relationship_string: "Starsky/Hutch",
               character_string: "Starsky,hutch",
               notes: "<p>Notes</p>",
               tag_string: "youpi",
               collection_names: "",
               private: "0",
               rec: "0" }

  describe "Valid API bookmark import" do
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

    it "should not create duplicate bookmarks for the same archivist and external URL" do
      pseud_id = @user.default_pseud.id
      post "/api/v1/bookmarks/import",
           { archivist: @user.login,
             bookmarks: [ bookmark, bookmark ]
           }.to_json,
           valid_headers
      bookmarks = Bookmark.find_all_by_pseud_id(pseud_id)
      assert_equal bookmarks.count, 1
    end

    it "should pass back any original references unchanged" do
      post "/api/v1/bookmarks/import",
           { archivist: @user.login,
             bookmarks: [ bookmark ]
           }.to_json,
           valid_headers
      bookmark_response = JSON.parse(response.body, symbolize_names: true)[:bookmarks].first
      assert_equal "123", bookmark_response[:original_id], "Original reference should be passed back unchanged"
      assert_equal "http://foo.com", bookmark_response[:original_url], "Original URL should be passed back unchanged"
    end

    it "should respond with the URL of the created bookmark" do
      pseud_id = @user.default_pseud.id
      post "/api/v1/bookmarks/import",
           { archivist: @user.login,
             bookmarks: [ bookmark ]
           }.to_json,
           valid_headers
      first_bookmark = Bookmark.find_all_by_pseud_id(pseud_id).first
      bookmark_response = JSON.parse(response.body, symbolize_names: true)[:bookmarks].first
      assert_equal bookmark_response[:archive_url], bookmark_url(first_bookmark)
    end

    WebMock.allow_net_connect!
  end

  describe "Invalid API bookmark import" do
    before do
      mock_external
      @user = create(:user)
    end

    after do
      WebMock.reset!
    end


    it "should return 400 Bad Request if no bookmarks are specified" do
      post "/api/v1/bookmarks",
           { archivist: @user.login }.to_json,
           valid_headers
      assert_equal 400, response.status
    end

    it "should return an error mess if no URL is specified" do
      post "/api/v1/bookmarks",
           { archivist: @user.login,
             bookmarks: [ bookmark.except(:url) ]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
      bookmark_response = JSON.parse(response.body, symbolize_names: true)[:bookmarks].first
      assert_equal bookmark_response[:messages].first,
                   "This bookmark does not contain a URL to an external site. Please specify a valid, non-AO3 URL."
    end

    it "should return an error message if the URL is on AO3" do
      work = create(:work)
      post "/api/v1/bookmarks",
           { archivist: @user.login,
             bookmarks: [ bookmark.merge(url: work_url(work)) ]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
      bookmark_response = JSON.parse(response.body, symbolize_names: true)[:bookmarks].first
      assert_equal bookmark_response[:messages].first,
                   "Url could not be reached. If the URL is correct and the site is currently down, please try again later."
    end

    it "should return an error message if there is no fandom" do
      post "/api/v1/bookmarks",
           { archivist: @user.login,
             bookmarks: [ bookmark.merge(fandom_string: "") ]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
      bookmark_response = JSON.parse(response.body, symbolize_names: true)[:bookmarks].first
      assert_equal bookmark_response[:messages].first,
                   "This bookmark does not contain a fandom. Please specify a fandom."
    end

    it "should return an error message if there is no title" do
      post "/api/v1/bookmarks",
           { archivist: @user.login,
             bookmarks: [ bookmark.merge(title: "") ]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
      bookmark_response = JSON.parse(response.body, symbolize_names: true)[:bookmarks].first
      assert_equal bookmark_response[:messages].first, "Title can't be blank"
    end

    it "should return an error message if there is no author" do
      post "/api/v1/bookmarks",
           { archivist: @user.login,
             bookmarks: [ bookmark.merge(author: "") ]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
      bookmark_response = JSON.parse(response.body, symbolize_names: true)[:bookmarks].first
      assert_equal bookmark_response[:messages].first,
                   "This bookmark does not contain an external author name. Please specify an author."
    end
  end

  WebMock.allow_net_connect!
end
