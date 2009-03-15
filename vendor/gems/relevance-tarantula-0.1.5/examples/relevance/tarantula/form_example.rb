require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe "Relevance::Tarantula::Form large example" do
  before do
    @tag = Hpricot(<<END)
<form action="/session" method="post">
  <input name="authenticity_token" type="hidden" value="1be0d07c6e13669a87b8f52a3c7e1d1ffa77708d" />
  <input id="email" name="email" size="30" type="text" />
  <input id="password" name="password" size="30" type="password" />
  <input id="remember_me" name="remember_me" type="checkbox" value="1" />
  <input name="commit" type="submit" value="Log in" />
</form>
END
    @form = Relevance::Tarantula::Form.new(@tag.at('form'))
  end
  
  it "has an action" do
    @form.action.should == "/session"
  end
  
  it "has a method" do
    @form.method.should == "post"
  end
  
end

describe "A Relevance::Tarantula::Form" do
  it "defaults method to 'get'" do
    @tag = Hpricot("<form/>")
    @form = Relevance::Tarantula::Form.new(@tag.at('form'))
    @form.method.should == 'get'
  end
end

describe "A Relevance::Tarantula::Form with a hacked _method" do
  before do
    @tag = Hpricot(<<END)
<form action="/foo">
  <input name="authenticity_token" type="hidden" value="1be0d07c6e13669a87b8f52a3c7e1d1ffa77708d" />
  <input id="_method" name="_method" size="30" type="text" value="PUT"/>
</form>
END
    @form = Relevance::Tarantula::Form.new(@tag.at('form'))
  end

  it "has a method" do
    @form.method.should == "put"
  end
  
end