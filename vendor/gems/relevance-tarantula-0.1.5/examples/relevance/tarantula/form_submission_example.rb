require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe "Relevance::Tarantula::FormSubmission" do
  
  # TODO: add more from field types to this example form as needed
  before do
    @tag = Hpricot(<<END)
<form action="/session" method="post">
  <input id="email" name="email" size="30" type="text" />
  <textarea id="comment" name="comment"value="1" />
  <input name="commit" type="submit" value="Postit" />
  <input name="secret" type="hidden" value="secret" />
  <select id="foo_opened_on_1i" name="foo[opened_on(1i)]">
    <option value="2003">2003</option>
    <option value="2004">2004</option>
  </select> 
</form>
END
    @form = Relevance::Tarantula::Form.new(@tag.at('form'))
    @fs = Relevance::Tarantula::FormSubmission.new(@form)
  end
  
  it "can mutate text areas" do
    @fs.stubs(:random_int).returns("42")
    @fs.mutate_text_areas(@form).should == {"comment" => "42"}
  end
  
  it "can mutate selects" do
    Hpricot::Elements.any_instance.stubs(:rand).returns(stub(:[] => "2006-stub"))
    @fs.mutate_selects(@form).should == {"foo[opened_on(1i)]" => "2006-stub"}
  end
  
  it "can mutate inputs" do
    @fs.stubs(:random_int).returns("43")
    @fs.mutate_inputs(@form).should == {"commit"=>"43", "secret"=>"43", "email"=>"43"}
  end

  it "has a signature based on action and fields" do
    @fs.signature.should == ['/session', [
      "comment", 
      "commit", 
      "email", 
      "foo[opened_on(1i)]", 
      "secret"]]
  end
  
  it "has a friendly to_s" do
    @fs.to_s.should =~ %r{^/session post}
  end
  
  it "can generate a random whole number" do
    @fs.random_whole_number.should >= 0
    Fixnum.should === @fs.random_whole_number
  end
end

describe "Relevance::Tarantula::FormSubmission for a crummy form" do
  before do
    @tag = Hpricot(<<END)
<form action="/session" method="post">
  <input value="no_name" />
</form>
END
    @form = Relevance::Tarantula::Form.new(@tag.at('form'))
    @fs = Relevance::Tarantula::FormSubmission.new(@form)
  end
  
  it "ignores unnamed inputs" do
    @fs.mutate_inputs(@form).should == {}
  end
end
