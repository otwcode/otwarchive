require "spec_helper"

describe PathCleaner do
  include PathCleaner

  describe "#relative_uri" do
    it "allows valid relative paths" do
      expect(relative_path("/")).to eq("/")
      expect(relative_path("/path")).to eq("/path")
      expect(relative_path("/foo/bar/")).to eq("/foo/bar/")
      expect(relative_path("/path?query=true")).to eq("/path?query=true")
      expect(relative_path("/path#anchor")).to eq("/path#anchor")
    end

    it "does not allow protocol relative paths" do
      expect(relative_path("//archiveofourown.org")).to eq(nil)
      expect(relative_path("//archiveofourown.org/path")).to eq(nil)
    end

    it "does not allow urls with a scheme" do
      expect(relative_path("http://archiveofourown.org")).to eq(nil)
      expect(relative_path("https://archiveofourown.org")).to eq(nil)
      expect(relative_path("mailto:test@archiveofourown.org")).to eq(nil)
      expect(relative_path("javascript:alert('test')")).to eq(nil)
    end

    it "does not allow urls with a host" do
      expect(relative_path("archiveofourown.org")).to eq(nil)
      expect(relative_path("www.archiveofourown.org/path")).to eq(nil)
    end

    it "does not allow urls with login credentials" do
      expect(relative_path("//:pass@/path")).to eq(nil)
      expect(relative_path("//user@/path")).to eq(nil)
      expect(relative_path("//user@archiveofourown.org")).to eq(nil)
      expect(relative_path("https://user:pass@archiveofourown.org/path")).to eq(nil)
      expect(relative_path("http://user:pass@/path")).to eq(nil)
    end

    it "does not allow urls with a port" do
      expect(relative_path("//:100/path")).to eq(nil)
      expect(relative_path("archiveofourown.org:100/path")).to eq(nil)
    end
  end
end
