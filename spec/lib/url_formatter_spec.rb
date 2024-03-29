require 'url_formatter'

describe UrlFormatter do

  describe '#original' do
    it "should return the given url" do
      url = "http://ao3.org"
      expect(UrlFormatter.new(url).original).to eq(url)
    end
  end

  describe "#minimal" do
    it "should remove anchors and query parameters from url containing no 'www'" do
      url = "http://ao3.org?evil=false#monkeys"
      expect(UrlFormatter.new(url).minimal).to eq("http://ao3.org")
    end
    it "should remove all parameters except \"sid\" for eFiction sites" do
      url = "http://eFiction.com/viewstory.php?param=foo&sid=123#comments"
      expect(UrlFormatter.new(url).minimal).to eq("http://eFiction.com/viewstory.php?sid=123")
    end
  end

  describe "minimal_no_protocol_no_www" do
    it "should handle http url containing 'www'" do
      url = "http://www.ao3.org?evil=false#monkeys"
      expect(UrlFormatter.new(url).minimal_no_protocol_no_www).to eq("ao3.org")
    end
    it "should handle http url NOT containing 'www'" do
      url = "http://ao3.org?evil=false#monkeys"
      expect(UrlFormatter.new(url).minimal_no_protocol_no_www).to eq("ao3.org")
    end
    it "should handle httpS url containing 'www'" do
      url = "https://ao3.org?evil=false#monkeys"
      expect(UrlFormatter.new(url).minimal_no_protocol_no_www).to eq("ao3.org")
    end
    it "should handle httpS url NOT containing 'www'" do
      url = "https://ao3.org?evil=false#monkeys"
      expect(UrlFormatter.new(url).minimal_no_protocol_no_www).to eq("ao3.org")
    end
  end

  describe "#no_www" do
    it "should remove www from the url" do
      url = "http://www.ao3.org"
      expect(UrlFormatter.new(url).no_www).to eq("http://ao3.org")
    end
    it "should remove www, query parameters and anchors from the url" do
      url = "http://www.ao3.org/123?evil=false#monkeys"
      expect(UrlFormatter.new(url).no_www).to eq("http://ao3.org/123")
    end
  end

  describe "#with_www" do
    it "should add www to the url" do
      url = "http://ao3.org"
      expect(UrlFormatter.new(url).with_www).to eq("http://www.ao3.org")
    end
    it "should add www to the url and remove query parameters and anchors" do
      url = "http://ao3.org?evil=false#monkeys"
      expect(UrlFormatter.new(url).with_www).to eq("http://www.ao3.org")
    end
  end

  describe "#with_http" do
    it "should add http:// to the url" do
      url = "ao3.org"
      expect(UrlFormatter.new(url).with_http).to eq("http://ao3.org")
    end
    it "should switch https to http and remove query parameters and anchors" do
      url = "https://ao3.org?evil=false#monkeys"
      expect(UrlFormatter.new(url).with_http).to eq("http://ao3.org")
    end
  end

  describe "#with_https" do
    it "should add https:// to the url" do
      url = "ao3.org"
      expect(UrlFormatter.new(url).with_https).to eq("https://ao3.org")
    end
    it "should switch http to https and remove query parameters and anchors" do
      url = "http://ao3.org?evil=false#monkeys"
      expect(UrlFormatter.new(url).with_https).to eq("https://ao3.org")
    end
  end

  describe "#encoded" do
    it "should URI encode the url" do
      url = "http://ao3.org/why would you do this"
      expect(UrlFormatter.new(url).encoded).to eq("http://ao3.org/why%20would%20you%20do%20this")
    end
  end

  describe "#decoded" do
    it "should URI decode the url" do
      url = "http://ao3.org/why%20would%20you%20do%20this"
      expect(UrlFormatter.new(url).decoded).to eq("http://ao3.org/why would you do this")
    end
  end

  describe "#standardized" do
    it "should add http" do
      expect(UrlFormatter.new("ao3.org").standardized.to_s).to eq("http://ao3.org")
    end
    it "should downcase the domain" do
      url = "http://YAYCAPS.COM/ILOVECAPS"
      expect(UrlFormatter.new(url).standardized.to_s).to eq("http://yaycaps.com/ILOVECAPS")
    end
  end

end
