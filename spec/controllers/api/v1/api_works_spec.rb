require "spec_helper"
require "controllers/api/api_helper"

include ApiHelper

describe "API v1 WorksController - Create works", type: :request do

  describe "API import with a valid archivist" do
    let(:archivist) { create(:archivist) }

    before :all do
      mock_external
    end

    after :all do
      WebMock.reset!
    end

    it "should not support the deprecated /import end-point", type: :routing do
      expect(post: "/api/v1/import").not_to be_routable
    end

    it "should return 200 OK when all stories are created" do
      valid_params = {
        archivist: archivist.login,
        works: [
          { external_author_name: "bar",
            external_author_email: "bar@foo.com",
            chapter_urls: ["http://foo"] }
        ]
      }

      post "/api/v1/works", params: valid_params.to_json, headers: valid_headers

      assert_equal 200, response.status
    end

    it "should return 200 OK with an error message when no stories are created" do
      valid_params = {
        archivist: archivist.login,
        works: [
          { external_author_name: "bar",
            external_author_email: "bar@foo.com",
            chapter_urls: ["http://bar"] }
        ]
      }

      post "/api/v1/works", params: valid_params.to_json, headers: valid_headers

      assert_equal 200, response.status
    end

    it "should return 200 OK with an error message when only some stories are created" do
      valid_params = {
        archivist: archivist.login,
        works: [
          { external_author_name: "bar",
            external_author_email: "bar@foo.com",
            chapter_urls: ["http://foo"] },
          { external_author_name: "bar2",
            external_author_email: "bar2@foo.com",
            chapter_urls: ["http://foo"] }
        ]
      }

      post "/api/v1/works", params: valid_params.to_json, headers: valid_headers

      assert_equal 200, response.status
    end

    it "should return the original id" do
      valid_params = {
        archivist: archivist.login,
        works: [
          { id: "123",
            external_author_name: "bar",
            external_author_email: "bar@foo.com",
            chapter_urls: ["http://foo"] }
        ]
      }

      post "/api/v1/works", params: valid_params.to_json, headers: valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_body[:works].first[:original_id]).to eq("123")
    end

    it "should send claim emails if send_claim_email is true" do
      # This test hits the call to #send_external_invites in #create for coverage
      # but can't find a way to verify its side-effect (calling ExternalAuthor#find_or_invite)
      valid_params = {
        archivist: archivist.login,
        send_claim_emails: 1,
        works: [
          { id: "123",
            external_author_name: "bar",
            external_author_email: "send_invite@ao3.org",
            chapter_urls: ["http://foo"] }
        ]
      }

      post "/api/v1/works", params: valid_params.to_json, headers: valid_headers
    end

    it "should return 400 Bad Request if no works are specified" do
      valid_params = {
        archivist: archivist.login
      }

      post "/api/v1/works", params: valid_params.to_json, headers: valid_headers

      assert_equal 400, response.status
    end

    it "should return a helpful message if the external work contains no text" do
      valid_params = {
        archivist: archivist.login,
        works: [
          { external_author_name: "bar",
            external_author_email: "bar@foo.com",
            chapter_urls: ["http://no-content"] }
        ]
      }

      post "/api/v1/works", params: valid_params.to_json, headers: valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_body[:works].first[:messages].first).to start_with("We couldn't")
    end

    describe "Provided API metadata should be used if present" do
      before(:all) do
        Rails.cache.clear

        mock_external

        archivist = create(:archivist)

        valid_params = {
          archivist: archivist.login,
          works: [
            { id: "123",
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
              chapter_urls: ["http://foo"] }
          ]
        }

        post "/api/v1/works", params: valid_params.to_json, headers: valid_headers
        parsed_body = JSON.parse(response.body, symbolize_names: true)

        @work = Work.find_by_url(parsed_body[:works].first[:original_url])
      end

      after(:all) do
        @work.destroy if @work
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

        archivist = create(:archivist)

        valid_params = {
          archivist: archivist.login,
          works: [
            { external_author_name: api_fields[:external_author_name],
              external_author_email: api_fields[:external_author_email],
              chapter_urls: ["http://foo"] }
          ]
        }

        post "/api/v1/works", params: valid_params.to_json, headers: valid_headers

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        @work = Work.find_by_url(parsed_body[:works].first[:original_url])
        created_user = ExternalAuthor.find_by(email: api_fields[:external_author_email])
        created_user.destroy unless created_user.nil?
      end

      after(:all) do
        @work.destroy if @work
        WebMock.reset!
      end

      it "Title should be detected from the content" do
        expect(@work.title).to eq(content_fields[:title])
      end
      it "Summary should be detected from the content" do
        expect(@work.summary).to eq("<p>" + content_fields[:summary] + "</p>")
      end
      it "Date should be detected from the content" do
        expect(@work.revised_at.to_date).to eq(content_fields[:date].to_date)
      end
      it "Chapter title should be detected from the content" do
        expect(@work.chapters.first.title).to eq(content_fields[:chapter_title])
      end
      it "Fandoms should be detected from the content" do
        expect(@work.fandoms.first.name).to eq(content_fields[:fandoms])
      end
      it "Warnings should be detected from the content" do
        expect(@work.warnings.first.name).to eq(content_fields[:warnings])
      end
      it "Characters should be detected from the content" do
        expect(@work.characters.flat_map(&:name)).to eq(content_fields[:characters].split(", "))
      end
      it "Ratings should be detected from the content" do
        expect(@work.ratings.first.name).to eq(content_fields[:rating])
      end
      it "Relationships should be detected from the content" do
        expect(@work.relationships.first.name).to eq(content_fields[:relationships])
      end
      it "Categories should be detected from the content" do
        expect(@work.categories).to be_empty
      end
      it "Additional Tags should be detected from the content" do
        expect(@work.freeforms.flat_map(&:name)).to eq(content_fields[:freeform].split(", "))
      end
      it "Notes should be detected from the content" do
        expect(@work.notes).to eq("<p>" + content_fields[:notes] + "</p>")
      end
    end

    describe "Imports should use fallback values or nil if no metadata is supplied" do
      before(:all) do
        mock_external

        archivist = create(:archivist)

        valid_params = {
          archivist: archivist.login,
          works: [
            { external_author_name: api_fields[:external_author_name],
              external_author_email: api_fields[:external_author_email],
              chapter_urls: ["http://no-metadata"] }
          ]
        }

        post "/api/v1/works", params: valid_params.to_json, headers: valid_headers

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        @work = Work.find_by_url(parsed_body[:works].first[:original_url])
      end

      after(:all) do
        @work.destroy if @work
        WebMock.reset!
      end

      it "Title should be the default fallback title for imported works" do
        expect(@work.title).to eq("Untitled Imported Work")
      end
      it "Summary should be blank" do
        expect(@work.summary).to eq("")
      end
      it "Date should be todayish" do
        expect(@work.created_at.utc.to_date).to eq(DateTime.now.utc.to_date)
      end
      it "Chapter title should be blank" do
        expect(@work.chapters.first.title).to be_nil
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

    describe "Provided API metadata should be used if present and tag detection is turned off" do
      before(:all) do
        mock_external

        archivist = create(:archivist)

        valid_params = {
          archivist: archivist.login,
          works: [
            { id: "123",
              title: api_fields[:title],
              detect_tags: false,
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
              chapter_urls: ["http://foo"] }
          ]
        }

        post "/api/v1/works", params: valid_params.to_json, headers: valid_headers

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        @work = Work.find_by_url(parsed_body[:works].first[:original_url])
      end

      after(:all) do
        @work.destroy if @work
        WebMock.reset!
      end

      it "API should override content for Title" do
        expect(@work.title).to eq(api_fields[:title])
      end
      it "API should override content for Summary" do
        expect(@work.summary).to eq("<p>" + api_fields[:summary] + "</p>")
      end
      it "Date should be detected from the content" do
        expect(@work.revised_at.to_date).to eq(content_fields[:date].to_date)
      end
      it "Chapter title should be detected from the content" do
        expect(@work.chapters.first.title).to eq(content_fields[:chapter_title])
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

    describe "Some fields should be detected and others use fallback values or nil if no metadata is supplied and tag detection is turned off" do
      before(:all) do
        mock_external

        archivist = create(:archivist)

        valid_params = {
          archivist: archivist.login,
          works: [
            { external_author_name: api_fields[:external_author_name],
              external_author_email: api_fields[:external_author_email],
              detect_tags: false,
              chapter_urls: ["http://foo"] }
          ]
        }

        post "/api/v1/works", params: valid_params.to_json, headers: valid_headers

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        @work = Work.find_by_url(parsed_body[:works].first[:original_url])
      end

      after(:all) do
        @work.destroy if @work
        WebMock.reset!
      end

      it "Title should be detected from the content" do
        expect(@work.title).to eq(content_fields[:title])
      end
      it "Summary should be detected from the content" do
        expect(@work.summary).to eq("<p>" + content_fields[:summary] + "</p>")
      end
      it "Date should be detected from the content" do
        expect(@work.revised_at.to_date).to eq(content_fields[:date].to_date)
      end
      it "Chapter title should be detected from the content" do
        expect(@work.chapters.first.title).to eq(content_fields[:chapter_title])
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

describe "API v1 WorksController - Find Works", type: :request do
  describe "valid work URL request" do
    work = FactoryGirl.create(:posted_work, imported_from_url: "foo")

    it "should return 200 OK" do
      valid_params = { original_urls: %w(bar foo) }

      post "/api/v1/works/urls", params: valid_params.to_json, headers: valid_headers

      assert_equal 200, response.status
    end

    it "should return the work URL for an imported work" do
      valid_params = { original_urls: %w(foo) }

      post "/api/v1/works/urls", params: valid_params.to_json, headers: valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_body.first[:status]).to eq "ok"
      expect(parsed_body.first[:work_url]).to eq work_url(work)
      expect(parsed_body.first[:created].to_date).to eq work.created_at.to_date
    end

    it "should return the original reference if one was provided" do
      valid_params = { original_urls: [{ id: "123", url: "foo" }] }

      post "/api/v1/works/urls", params: valid_params.to_json, headers: valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_body.first[:status]).to eq "ok"
      expect(parsed_body.first[:original_id]).to eq "123"
      expect(parsed_body.first[:original_url]).to eq "foo"
    end

    it "should return an error when no URLs are provided" do
      valid_params = { original_urls: [] }

      post "/api/v1/works/urls", params: valid_params.to_json, headers: valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_body.first[:error]).to eq "Please provide a list of URLs to find."
    end

    it "should return an error when too many URLs are provided" do
      loads_of_items = Array.new(210) { |_| "url" }
      valid_params = { original_urls: loads_of_items }

      post "/api/v1/works/urls", params: valid_params.to_json, headers: valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_body.first[:error]).to start_with "Please provide no more than"
    end

    it "should return an error for a work that wasn't imported" do
      valid_params = { original_urls: %w(bar) }

      post "/api/v1/works/urls", params: valid_params.to_json, headers: valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_body.first[:status]).to eq("not_found")
      expect(parsed_body.first).to include(:error)
    end

    it "should only do an exact match on the original url" do
      valid_params = { original_urls: %w(fo food) }

      post "/api/v1/works/urls", params: valid_params.to_json, headers: valid_headers
      parsed_body = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_body.first[:status]).to eq("not_found")
      expect(parsed_body.first).to include(:error)
      expect(parsed_body.second[:status]).to eq("not_found")
      expect(parsed_body.second).to include(:error)
    end
  end
end

describe "API v1 WorksController - Unit Tests", type: :request do
  before do
    @under_test = Api::V1::WorksController.new
  end

  it "work_url_from_external should return an error message when the work URL is blank" do
    work_url_response = @under_test.instance_eval { work_url_from_external("user", "") }
    expect(work_url_response[:error]).to eq "Please provide the original URL for the work."
  end

  it "send_external_invites should call find_or_invite on each external author" do
    user = create(:user)
    author1 = create(:external_author)
    author2 = create(:external_author)
    work = create(:work)
    name1 = create(:external_author_name, name: 'n1', external_author: author1)
    name2 = create(:external_author_name, name: 'n2', external_author: author2)
    create(:external_creatorship, external_author_name: name1, creation: work)
    create(:external_creatorship, external_author_name: name2, creation: work)

    @under_test.instance_eval { send_external_invites([work], user) }
    expect(Invitation.all.map(&:invitee_email)).to include(author1.email)
    expect(Invitation.all.map(&:invitee_email)).to include(author2.email)
  end

  describe "work_errors" do
    it "should return an error if a work doesn't contain chapter urls" do
      work = { chapter_urls: [] }
      error_message = @under_test.instance_eval { work_errors(work) }
      expect(error_message[1][0]).to start_with "This work doesn't contain chapter_urls."
    end

    it "should return an error if a work has too many chapters" do
      loads_of_items = Array.new(210) { |_| "chapter_url" }
      work = { chapter_urls: loads_of_items }
      error_message = @under_test.instance_eval { work_errors(work) }
      expect(error_message[1][0]).to start_with "This work contains too many chapter URLs"
    end
  end
end
