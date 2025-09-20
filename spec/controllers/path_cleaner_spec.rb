require "spec_helper"

describe PathCleaner do
  include PathCleaner

  describe "#relative_uri" do
    it "allows valid relative paths" do
      expect(relative_path("/")).to_not eq(nil)
      expect(relative_path("/path")).to_not eq(nil)
      expect(relative_path("/foo/bar/")).to_not eq(nil)
      expect(relative_path("/path?query=true")).to_not eq(nil)
      expect(relative_path("/path#anchor")).to_not eq(nil)
    end

    it "does not allow protocol relative paths" do
      expect(relative_path("//example.com")).to eq(nil)
      expect(relative_path("//example.com/path")).to eq(nil)
    end

    it "does not allow urls with a scheme" do
      expect(relative_path("http://example.com")).to eq(nil)
      expect(relative_path("https://example.com")).to eq(nil)
      expect(relative_path("mailto:test@example.com")).to eq(nil)
      expect(relative_path("javascript:alert('test')")).to eq(nil)
    end

    it "does not allow urls with a host" do
      expect(relative_path("example.com")).to eq(nil)
      expect(relative_path("www.example.com/path")).to eq(nil)
    end
  end
end
