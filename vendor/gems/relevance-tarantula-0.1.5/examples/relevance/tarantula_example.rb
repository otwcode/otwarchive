require File.join(File.dirname(__FILE__), "..", "example_helper.rb")

describe Relevance::Tarantula do
  include Relevance::Tarantula
  attr_accessor :verbose
  
  it "writes to stdout if verbose" do
    self.verbose = true
    expects(:puts).with("foo")
    log("foo")
  end

  it "swallows output if !verbose" do
    self.verbose = false
    expects(:puts).never
    log("foo")
  end
  
  it "puts RAILS_ROOT behind a method call" do
    lambda{rails_root}.should raise_error(NameError)
  end
end

