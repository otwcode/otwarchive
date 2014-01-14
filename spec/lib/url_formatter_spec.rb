require 'url_formatter'

describe UrlFormatter do
 
  describe '#original' do
    it "should return the given url" do
      url = "http://ao3.org"
      UrlFormatter.new(url).original.should == url
    end
  end

  describe '#minimal' do
    it "should remove anchors and query parameters from url" do
      url = "http://ao3.org#monkeys?evil=false"
      UrlFormatter.new(url).minimal.should == "http://ao3.org"
    end
  end
  
  describe '#no_www' do
    it "should remove www from the url" do
      url = "http://www.ao3.org"
      UrlFormatter.new(url).no_www.should == "http://ao3.org"
    end
  end
  
  describe '#with_www' do
    it "should add www to the url" do
      url = "http://ao3.org"
      UrlFormatter.new(url).with_www.should == "http://www.ao3.org"
    end
  end
  
  describe '#encoded' do
    it "should URI encode the url" do
      url = "http://ao3.org/why would you do this"
      UrlFormatter.new(url).encoded.should == "http://ao3.org/why%20would%20you%20do%20this"
    end
  end
  
  describe '#decoded' do
    it "should URI decode the url" do
      url = "http://ao3.org/why%20would%20you%20do%20this"
      UrlFormatter.new(url).decoded.should == "http://ao3.org/why would you do this"
    end
  end
  
  describe '#standardized' do
    it "should add http" do
      UrlFormatter.new('ao3.org').standardized.should == "http://ao3.org"
    end
    it "should downcase the domain" do
      url = "http://YAYCAPS.COM/ILOVECAPS"
      UrlFormatter.new(url).standardized.should == "http://yaycaps.com/ILOVECAPS"
    end
  end
 
end
