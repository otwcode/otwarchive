require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe "Relevance::Tarantula::Result" do
  before do
    @result = Relevance::Tarantula::Result.new(
        :success => true, 
        :method => "get", 
        :url => "/some/url?arg1=foo&arg2=bar"
    )
  end
  
  it "has a short description" do
    @result.short_description.should == "get /some/url?arg1=foo&arg2=bar"
  end
  
  it "has a sequence number" do
    @result.class.next_number = 0
    @result.sequence_number.should == 1
    @result.class.next_number.should == 1
  end
  
  it "has link to the url at localhost" do
    @result.full_url.should == "http://localhost:3000/some/url?arg1=foo&arg2=bar"
  end
  
end

describe "Relevance::Tarantula::Result class methods" do
  before do
    @rh = Relevance::Tarantula::Result
  end
  
  it "defines HTTP responses that are considered 'successful' when spidering" do
    %w{200 201 302 401}.each do |code|
      @rh.successful?(stub(:code => code)).should == true
    end
  end
  
  it "adds successful responses to success collection" do
    stub = stub_everything(:code => "200")
    @rh.handle(Relevance::Tarantula::Result.new(:response => stub)).success.should == true
  end

  it "adds failed responses to failure collection" do
    stub = stub_everything(:code => "500")
    result = @rh.handle(Relevance::Tarantula::Result.new(:response => stub))
    result.success.should == false
    result.description.should == "Bad HTTP Response"
  end
  
end

describe "Relevance::Tarantula::Result allowed errors" do
  before do
    Relevance::Tarantula::Result.allow_errors_for = {}
  end
  
  it "defaults to *not* skip errors" do
    Relevance::Tarantula::Result.can_skip_error?(stub(:code => "404")).should == false
  end

  it "can skip errors matching code and url" do
    Relevance::Tarantula::Result.allow_errors_for = {"404" => [/some_url/]}
    Relevance::Tarantula::Result.can_skip_error?(stub(:code => "404", :url => "this_is_some_url")).should == true
  end

  it "does not skip errors matching code only" do
    Relevance::Tarantula::Result.allow_errors_for = {"404" => [/some_other_url/]}
    Relevance::Tarantula::Result.can_skip_error?(stub(:code => "404", :url => "this_is_some_url")).should == false
  end
  
  it "users allow_nnn_for syntax to specify allowed errors" do
    Relevance::Tarantula::Result.allow_404_for(/this_url/)
    Relevance::Tarantula::Result.allow_errors_for.should == {"404" => [/this_url/]}
    Relevance::Tarantula::Result.allow_404_for(/another_url/)
    Relevance::Tarantula::Result.allow_errors_for.should == {"404" => [/this_url/, /another_url/]}
  end
  
  it "chains to super method missing" do
    lambda{Relevance::Tarantula::Result.allow_xxx_for}.should raise_error(NoMethodError)
  end
  
end


