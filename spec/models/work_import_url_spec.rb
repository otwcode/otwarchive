require "spec_helper"

describe WorkImportUrl do
  describe "variant computation" do
    it "computes minimal and minimal_no_protocol_no_www on create" do
      work = create(:work)
      import_url = WorkImportUrl.create!(work: work, url: "http://www.example.com/story.html?style=mine")

      expect(import_url.minimal).to eq("http://www.example.com/story.html")
      expect(import_url.minimal_no_protocol_no_www).to eq("example.com/story.html")
    end

    it "preserves sid parameter for eFiction sites" do
      work = create(:work)
      import_url = WorkImportUrl.create!(work: work, url: "http://efiction-site.com/viewstory.php?sid=123&warning=3")

      expect(import_url.minimal).to eq("http://efiction-site.com/viewstory.php?sid=123")
      expect(import_url.minimal_no_protocol_no_www).to eq("efiction-site.com/viewstory.php?sid=123")
    end

    it "recomputes variants on update" do
      work = create(:work)
      import_url = WorkImportUrl.create!(work: work, url: "http://example.com/old-story")
      import_url.update!(url: "https://www.example.com/new-story?color=blue")

      expect(import_url.minimal).to eq("https://www.example.com/new-story")
      expect(import_url.minimal_no_protocol_no_www).to eq("example.com/new-story")
    end
  end

  describe "validations" do
    it "requires a url" do
      work = create(:work)
      import_url = WorkImportUrl.new(work: work, url: nil)
      expect(import_url).not_to be_valid
      expect(import_url.errors[:url]).to include("can't be blank")
    end

    it "enforces uniqueness on work_id" do
      work = create(:work)
      WorkImportUrl.create!(work: work, url: "http://example.com/story1")
      duplicate = WorkImportUrl.new(work: work, url: "http://example.com/story2")
      expect(duplicate).not_to be_valid
    end
  end

  describe ".find_work_by_url" do
    it "finds a work by exact URL match" do
      url = "http://foo.com/bar.html"
      work = create(:work, imported_from_url: url)
      expect(WorkImportUrl.find_work_by_url(url)).to eq(work)
    end

    it "finds a work with different query parameters" do
      work = create(:work, imported_from_url: "http://lj-site.com/thing1?style=mine")
      expect(WorkImportUrl.find_work_by_url("http://lj-site.com/thing1?style=other")).to eq(work)
    end

    it "finds a work across http/https variants" do
      work = create(:work, imported_from_url: "http://lj-site.com/thing1?style=mine")
      expect(WorkImportUrl.find_work_by_url("https://lj-site.com/thing1?style=other")).to eq(work)
    end

    it "finds a work across www/non-www variants" do
      work = create(:work, imported_from_url: "http://www.testme.org/story.html")
      expect(WorkImportUrl.find_work_by_url("http://testme.org/story.html")).to eq(work)
    end

    it "does not mix up works with different eFiction sid parameters" do
      create(:work, imported_from_url: "http://efiction-site.com/viewstory.php?sid=123")
      expect(WorkImportUrl.find_work_by_url("http://efiction-site.com/viewstory.php?sid=456")).to be_nil
    end

    it "does not mix up works with similar but different paths" do
      create(:work, imported_from_url: "http://foo.com/12345")
      expect(WorkImportUrl.find_work_by_url("http://foo.com/123")).to be_nil
    end

    it "does not match partial path prefixes" do
      create(:work, imported_from_url: "http://www.foo.com/i-am-something")
      expect(WorkImportUrl.find_work_by_url("http://foo.com/i-am-something/else")).to be_nil
    end

    it "returns nil when no matching work exists" do
      expect(WorkImportUrl.find_work_by_url("http://nonexistent.com/story")).to be_nil
    end
  end

  describe "caching" do
    it "caches the result of find_work_by_url" do
      url = "http://lj-site.com/cached-thing"
      work = create(:work, imported_from_url: url)

      cache_key = WorkImportUrl.find_by_url_cache_key(url)
      expect(Rails.cache.read(cache_key)).to be_nil

      expect(WorkImportUrl.find_work_by_url(url)).to eq(work)
      expect(Rails.cache.read(cache_key)).to eq(work)
    end
  end
end
