require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))

describe "HashSmartMerge" do
  
  it "smart merge!" do
    one = { :foo => "123", :bar => "456" }
    two = { :bar => "789", :bat => "012" }
    one.smart_merge!(two)
    expected = { :foo => "123", :bar => ["456", "789"], :bat => "012" }
    assert_equal expected, one
  end
  
  it "smart merge with nils" do
    one = { :foo => "123", :bar => nil }
    two = { :bar => "789", :bat => "012" }
    one.smart_merge!(two)
    expected = { :foo => "123", :bar => [nil, "789"], :bat => "012" }
    assert_equal expected, one
  end
  
  it "smart merge with an array value" do
    one = { :foo => "123", :bar => ["566", "667"] }
    two = { :bar => "789", :bat => "012" }
    one.smart_merge!(two)
    expected = { :foo => "123", :bar => [["566", "667"], "789"], :bat => "012" }
    assert_equal expected, one
  end
  
  it "smart merge three hashes" do
    one = { :foo => "123", :bar => "456" }
    two = { :bar => "789", :bat => "012" }
    thr = { :bat => "556", :ant => "667" }
    one.smart_merge!(two)
    one.smart_merge!(thr)
    expected = { :foo => "123", :bar => ["456", "789"], :bat => ["012", "556"], :ant => "667" }
    assert_equal expected, one
  end
  
end