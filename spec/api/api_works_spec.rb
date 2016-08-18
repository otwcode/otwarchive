require 'spec_helper'
require 'api/api_helper'

include ApiHelper

describe "API WorksController - Create" do

  # Override is_archivist so all users are archivists from this point on
  class User < ActiveRecord::Base
    def is_archivist?
      true
    end
  end

  describe "API import with a valid archivist" do
    before do
      mock_external
      @user = create(:user)
    end

    after do
      WebMock.reset!
    end

    it "should support the deprecated /import end-point" do
      post "/api/v1/import",
           { archivist: @user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://foo"] }]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
    end

    it "should return 200 OK when all stories are created" do
      post "/api/v1/works",
           { archivist: @user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://foo"] }]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
    end

    it "should return 200 OK with an error message when no stories are created" do
      post "/api/v1/works",
           { archivist: @user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://bar"] }]
           }.to_json,
           valid_headers
      assert_equal 200, response.status
    end

    it "should return 200 OK with an error message when only some stories are created" do
      post "/api/v1/works",
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

    it "should return the original id" do
      post "/api/v1/works",
           { archivist: @user.login,
             works: [{ id: "123",
                       external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://foo"] }]
           }.to_json,
           valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_body[:works].first[:original_id]).to eq("123")
    end

    it "should return 400 Bad Request if no works are specified" do
      post "/api/v1/works",
           { archivist: @user.login }.to_json,
           valid_headers
      assert_equal 400, response.status
    end

    it "should return a helpful message if the external work contains no text" do
      post "/api/v1/works",
           { archivist: @user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://no-content"] }]
           }.to_json,
           valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_body[:works].first[:messages].first).to start_with("We couldn't")
    end

    describe "Provided API metadata should be used if present" do
      before(:all) do
        mock_external
        user = create(:user)
        post "/api/v1/import",
             { archivist: user.login,
               works: [{ id: "123",
                         title: api_fields[:title],
                         summary: api_fields[:summary],
                         fandoms: api_fields[:fandoms],
                         warnings: api_fields[:warnings],
                         characters: api_fields[:characters],
                         rating: api_fields[:rating],
                         relationships: api_fields[:relationships],
                         categories: api_fields[:categories],
                         additional_tags: api_fields[:freeform],
                         external_author_name: api_fields[:external_author_name],
                         external_author_email: api_fields[:external_author_email],
                         notes: api_fields[:notes],
                         chapter_urls: ["http://foo"] }]
             }.to_json,
             valid_headers

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        @work = Work.find_by_url(parsed_body[:works].first[:original_url])
      end

      after(:all) do
        @work.destroy
        WebMock.reset!
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
        mock_external
        user = create(:user)
        post "/api/v1/import",
             { archivist: user.login,
               works: [{ external_author_name: "bar",
                         external_author_email: "bar@foo.com",
                         chapter_urls: ["http://foo"] }]
             }.to_json,
             valid_headers

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        @work = Work.find_by_url(parsed_body[:works].first[:original_url])
      end

      after(:all) do
        @work.destroy
        WebMock.reset!
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
        mock_external
        user = create(:user)
        post "/api/v1/import",
             { archivist: user.login,
               works: [{ external_author_name: "bar",
                         external_author_email: "bar@foo.com",
                         chapter_urls: ["http://no-metadata"] }]
             }.to_json,
             valid_headers

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        @work = Work.find_by_url(parsed_body[:works].first[:original_url])
      end

      after(:all) do
        @work.destroy
        WebMock.reset!
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
end

describe "API WorksController - Find Works" do
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
      parsed_body = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_body.first[:status]).to eq "ok"
      expect(parsed_body.first[:work_url]).to eq work_url(@work)
      expect(parsed_body.first[:created]).to eq @work.created_at.as_json
    end

    it "should return the original reference if one was provided" do
      post "/api/v1/works/urls",
           { original_urls: [{ id: "123", url: "foo" }] }.to_json,
           valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_body.first[:status]).to eq "ok"
      expect(parsed_body.first[:original_id]).to eq "123"
      expect(parsed_body.first[:original_url]).to eq "foo"
    end

    it "should return an error for a work that wasn't imported" do
      post "/api/v1/works/urls",
           { original_urls: %w(bar) }.to_json,
           valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_body.first[:status]).to eq("not_found")
      expect(parsed_body.first).to include(:error)
    end

    it "should only do an exact match on the original url" do
      post "/api/v1/works/urls",
           { original_urls: %w(fo food) }.to_json,
           valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_body.first[:status]).to eq("not_found")
      expect(parsed_body.first).to include(:error)
      expect(parsed_body.second[:status]).to eq("not_found")
      expect(parsed_body.second).to include(:error)
    end
  end
end
