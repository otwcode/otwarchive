require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails_test_helper"))

describe "core extensions" do
  it "should extend Kernel" do
    Kernel.should.respond_to? :silence_warnings
  end
end