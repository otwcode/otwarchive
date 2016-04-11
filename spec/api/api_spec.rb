require 'spec_helper'
require 'webmock'

# set up a valid token and some headers
def valid_headers
  api = ApiKey.first_or_create!(name: "Test", access_token: "testabc")
  {
    "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Token.encode_credentials(api.access_token),
    "HTTP_ACCEPT" => "application/json",
    "CONTENT_TYPE" => "application/json"
  }
end

# Values in API fake content
def content_fields
  {
    title: "Foo Title", summary: "Foo summary", fandoms: "Foo Fandom", warnings: "Underage",
    characters: "foo 1, foo 2", rating: "Explicit", relationships: "foo 1/foo 2",
    categories: "F/F", freeform: "foo tag 1, foo tag 2", external_author_name: "bar",
    external_author_email: "bar@foo.com", notes: "This is a <i>content note</i>."
  }
end

def api_fields
  {
    title: "Bar Title", summary: "Bar summary", fandoms: "Bar Fandom", warnings: "Rape/Non-Con",
    characters: "bar 1, bar 2", rating: "General", relationships: "bar 1/bar 2",
    categories: "M/M", freeform: "bar tag 1, bar tag 2", external_author_name: "bar",
    external_author_email: "bar@foo.com", notes: "This is an <i>API note</i>."
  }
end

# Let the test get at external sites, but stub out anything containing "foo" or "bar"
def mock_external
  fields = content_fields

  WebMock.allow_net_connect!
  WebMock.stub_request(:any, /foo/).
    to_return(status: 200,
              body:
                "Title: #{fields[:title]}
Summary:  #{fields[:summary]}
Fandom:  #{fields[:fandoms]}
Rating: #{fields[:rating]}
Warnings:  #{fields[:warnings]}
Characters:  #{fields[:characters]}
Pairings:  #{fields[:relationships]}
Category:  #{fields[:categories]}
Tags:  #{fields[:freeform]}
Author's notes:  #{fields[:notes]}

stubbed response", headers: {})

  WebMock.stub_request(:any, /no-metadata/).
    to_return(status: 200,
              body: "stubbed response",
              headers: {})

  WebMock.stub_request(:any, /no-content/).
    to_return(status: 200,
              body: "",
              headers: {})

  WebMock.stub_request(:any, /bar/).
    to_return(status: 404, headers: {})
end

describe "API Authorization" do
  end_points = ["api/v1/import", "api/v1/works/import", "api/v1/bookmarks/import"]

  describe "API POST with invalid request" do
    it "should return 401 Unauthorized if no token is supplied" do
      end_points.each do |url|
        post url
        assert_equal 401, response.status
      end
    end

    it "should return 403 Forbidden if the specified user isn't an archivist" do
      end_points.each do |url|
        post url,
             { archivist: "mr_nobody" }.to_json,
             valid_headers
        assert_equal 403, response.status
      end
    end
  end
end

describe "API ImportController" do
  mock_external

  # Override is_archivist so all users are archivists from this point on
  class User < ActiveRecord::Base
    def is_archivist?
      true
    end
  end

  describe "API import with a valid archivist" do
    before do
      @user = create(:user)
    end

    it "should return 200 OK when all stories are created" do
      post "/api/v1/import",
           { archivist: @user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://foo"] }]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
    end

    it "should return 200 OK with an error message when no stories are created" do
      post "/api/v1/import",
           { archivist: @user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://bar"] }]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
    end

    it "should return 200 OK with an error message when only some stories are created" do
      post "/api/v1/import",
           { archivist: @user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://foo"] },
                     { external_author_name: "bar2",
                       external_author_email: "bar2@foo.com",
                       chapter_urls: ["http://foo"] }]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
    end

    it "should return 400 Bad Request if no works are specified" do
      post "/api/v1/import",
           { archivist: @user.login }.to_json,
           valid_headers
      assert_equal 400, response.status
    end

    it "should return a helpful message if the external work contains no text" do
      post "/api/v1/import",
           { archivist: @user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://no-content"] }]
           }.to_json,
           valid_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["works"].first["messages"].first).to start_with("We couldn't")
    end

    describe "Provided API metadata should be used if present" do
      before(:all) do
        fields = api_fields
        user = create(:user)
        post "/api/v1/import",
             { archivist: user.login,
               works: [{ title: fields[:title],
                         summary: fields[:summary],
                         fandoms: fields[:fandoms],
                         warnings: fields[:warnings],
                         characters: fields[:characters],
                         rating: fields[:rating],
                         relationships: fields[:relationships],
                         categories: fields[:categories],
                         additional_tags: fields[:freeform],
                         external_author_name: fields[:external_author_name],
                         external_author_email: fields[:external_author_email],
                         notes: fields[:notes],
                         chapter_urls: ["http://foo"] }]
             }.to_json,
             valid_headers

        parsed_body = JSON.parse(response.body)
        @work = Work.find_by_url(parsed_body["works"].first["original_url"])
      end

      after(:all) do
        @work.destroy
      end


      it "API should override content for Title" do
        expect(@work.title).to eq(api_fields[:title])
      end
      it "API should override content for Summary" do
        expect(@work.summary).to eq("<p>" + api_fields[:summary] + "</p>")
      end
      it "API should override content for Fandoms" do
        expect(@work.fandoms.first.name).to eq(api_fields[:fandoms])
      end
      it "API should override content for Warnings" do
        expect(@work.warnings.first.name).to eq(api_fields[:warnings])
      end
      it "API should override content for Characters" do
        expect(@work.characters.flat_map(&:name)).to eq(api_fields[:characters].split(", "))
      end
      it "API should override content for Ratings" do
        expect(@work.ratings.first.name).to eq(api_fields[:rating])
      end
      it "API should override content for Relationships" do
        expect(@work.relationships.first.name).to eq(api_fields[:relationships])
      end
      it "API should override content for Categories" do
        expect(@work.categories.first.name).to eq(api_fields[:categories])
      end
      it "API should override content for Additional Tags" do
        expect(@work.freeforms.flat_map(&:name)).to eq(api_fields[:freeform].split(", "))
      end
      it "API should override content for Notes" do
        expect(@work.notes).to eq("<p>" + api_fields[:notes] + "</p>")
      end
      it "API should override content for Author pseud" do
        expect(@work.external_author_names.first.name).to eq(api_fields[:external_author_name])
      end
    end

    describe "Metadata should be extracted from content if no API metadata is supplied" do
      before(:all) do
        user = create(:user)
        post "/api/v1/import",
             { archivist: user.login,
               works: [{ external_author_name: "bar",
                         external_author_email: "bar@foo.com",
                         chapter_urls: ["http://foo"] }]
             }.to_json,
             valid_headers

        parsed_body = JSON.parse(response.body)
        @work = Work.find_by_url(parsed_body["works"].first["original_url"])
      end

      after(:all) do
        @work.destroy
      end

      it "detected content metadata should be used for Title" do
        expect(@work.title).to eq(content_fields[:title])
      end
      it "detected content metadata should be used for Summary" do
        expect(@work.summary).to eq("<p>" + content_fields[:summary] + "</p>")
      end
      it "detected content metadata should be used for Fandoms" do
        expect(@work.fandoms.first.name).to eq(content_fields[:fandoms])
      end
      it "detected content metadata should be used for Warnings" do
        expect(@work.warnings.first.name).to eq(content_fields[:warnings])
      end
      it "detected content metadata should be used for Characters" do
        expect(@work.characters.flat_map(&:name)).to eq(content_fields[:characters].split(", "))
      end
      it "detected content metadata should be used for Ratings" do
        expect(@work.ratings.first.name).to eq(content_fields[:rating])
      end
      it "detected content metadata should be used for Relationships" do
        expect(@work.relationships.first.name).to eq(content_fields[:relationships])
      end
      it "detected content metadata should NOT be used for Categories" do
        expect(@work.categories).to be_empty
      end
      it "detected content metadata should be used for Additional Tags" do
        expect(@work.freeforms.flat_map(&:name)).to eq(content_fields[:freeform].split(", "))
      end
      it "detected content metadata should be used for Notes" do
        expect(@work.notes).to eq("<p>" + content_fields[:notes] + "</p>")
      end
      it "detected content metadata should be used for Author pseud" do
        expect(@work.external_author_names.first.name).to eq(api_fields[:external_author_name])
      end
    end

    describe "Imports should use fallback values or nil if no metadata is supplied" do
      before(:all) do
        user = create(:user)
        post "/api/v1/import",
             { archivist: user.login,
               works: [{ external_author_name: "bar",
                         external_author_email: "bar@foo.com",
                         chapter_urls: ["http://no-metadata"] }]
             }.to_json,
             valid_headers

        parsed_body = JSON.parse(response.body)
        @work = Work.find_by_url(parsed_body["works"].first["original_url"])
      end

      after(:all) do
        @work.destroy
      end

      it "Title should be 'Untitled Imported Work'" do
        expect(@work.title).to eq("Untitled Imported Work")
      end
      it "Summary should be blank" do
        expect(@work.summary).to eq("")
      end
      it "Fandoms should be the default Archive fandom ('No Fandom')" do
        expect(@work.fandoms.first.name).to eq(ArchiveConfig.FANDOM_NO_TAG_NAME)
      end
      it "Warnings should be the default Archive warning" do
        expect(@work.warnings.first.name).to eq(ArchiveConfig.WARNING_DEFAULT_TAG_NAME)
      end
      it "Characters should be empty" do
        expect(@work.characters).to be_empty
      end
      it "Ratings should be the default Archive rating" do
        expect(@work.ratings.first.name).to eq(ArchiveConfig.RATING_DEFAULT_TAG_NAME)
      end
      it "Relationships should be empty" do
        expect(@work.relationships).to be_empty
      end
      it "Categories should be empty" do
        expect(@work.categories).to be_empty
      end
      it "Additional Tags should be empty" do
        expect(@work.freeforms).to be_empty
      end
      it "Notes should be empty" do
        expect(@work.notes).to be_empty
      end
      it "Author pseud" do
        expect(@work.external_author_names.first.name).to eq(api_fields[:external_author_name])
      end
    end
  end

  WebMock.allow_net_connect!
end

describe "API BookmarksController" do
  mock_external

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
      @user = create(:user)
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
      user = create(:user)
      post "/api/v1/import",
           { archivist: @user.login }.to_json,
           valid_headers
      assert_equal 400, response.status
    end
  end

  WebMock.allow_net_connect!
end

describe "API WorksController" do
  before do
    @work = FactoryGirl.create(:work, posted: true, imported_from_url: "foo")
  end

  describe "valid work URL request" do
    it "should return 200 OK" do
      post "/api/v1/works/urls",
           { original_urls: %w(bar foo) }.to_json,
           valid_headers
      assert_equal 200, response.status
    end

    it "should return the work URL for an imported work" do
      post "/api/v1/works/urls",
           { original_urls: %w(foo) }.to_json,
           valid_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.first["status"]).to eq "ok"
      expect(parsed_body.first["work_url"]).to eq work_url(@work)
      expect(parsed_body.first["created"]).to eq @work.created_at.as_json
    end

    it "should return an error for a work that wasn't imported" do
      post "/api/v1/works/urls",
           { original_urls: %w(bar) }.to_json,
           valid_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.first["status"]).to eq("not_found")
      expect(parsed_body.first).to include("error")
    end

    it "should only do an exact match on the original url" do
      post "/api/v1/works/urls",
           { original_urls: %w(fo food) }.to_json,
           valid_headers
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.first["status"]).to eq("not_found")
      expect(parsed_body.first).to include("error")
      expect(parsed_body.second["status"]).to eq("not_found")
      expect(parsed_body.second).to include("error")
    end
  end
end
