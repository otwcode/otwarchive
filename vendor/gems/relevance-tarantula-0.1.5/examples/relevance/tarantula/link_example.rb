require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe "Relevance::Tarantula::Link" do
  include ActionView::Helpers::UrlHelper
  
  it "does not raise an error when initializing without href attribtue" do
    link = Relevance::Tarantula::Link.new(Hpricot('<a="/foo">foo</a>').at('a'))
    link.href.should == nil
    link.method.should == :get    
  end

  it "parses anchor tags" do
    link = Relevance::Tarantula::Link.new(Hpricot('<a href="/foo">foo</a>').at('a'))
    link.href.should == '/foo'
    link.method.should == :get
  end

  it "parses anchor tags with POST 'method'" do
    link = Relevance::Tarantula::Link.new(Hpricot(%Q{<a href="/foo" onclick="#{method_javascript_function(:post)}">foo</a>}).at('a'))
    link.href.should == '/foo'
    link.method.should == :post
  end

  it "parses anchor tags with PUT 'method'" do
    link = Relevance::Tarantula::Link.new(Hpricot(%Q{<a href="/foo" onclick="#{method_javascript_function(:put)}">foo</a>}).at('a'))
    link.href.should == '/foo'
    link.method.should == :put
  end

  it "parses anchor tags with DELETE 'method'" do
    link = Relevance::Tarantula::Link.new(Hpricot(%Q{<a href="/foo" onclick="#{method_javascript_function(:delete)}">foo</a>}).at('a'))
    link.href.should == '/foo'
    link.method.should == :delete
  end

  it "parses link tags with text" do
    link = Relevance::Tarantula::Link.new(Hpricot('<link href="/bar">bar</a>').at('link'))
    link.href.should == '/bar'
    link.method.should == :get
  end
  
  it "parses link tags without text" do
    link = Relevance::Tarantula::Link.new(Hpricot('<link href="/bar" />').at('link'))
    link.href.should == '/bar'
    link.method.should == :get
  end
  
  # method_javascript_function needs this method
  def protect_against_forgery?
    false
  end
  
end

describe "possible conflict when user has an AR model named Link" do
  it "does not taint Object with Relevance::Tarantula" do
    Object.ancestors.should_not include(Relevance::Tarantula)
  end
  
  it "doesnt break with a Link model" do
    lambda {
      class Link < ActiveRecord::Base
      end
    }.should_not raise_error
  end
  
end