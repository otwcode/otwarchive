require 'spec/spec_helper'

describe Riddle::Client::Response do
  it "should interpret an integer correctly" do
    Riddle::Client::Response.new([42].pack('N')).next_int.should == 42
  end
  
  it "should interpret a string correctly" do
    str = "this is a string"
    Riddle::Client::Response.new(
      [str.length].pack('N') + str
    ).next.should == str
  end
  
  # Comparing floats with decimal places doesn't seem to be exact
  it "should interpret a float correctly" do
    Riddle::Client::Response.new([1.0].pack('f').unpack('L*').pack('N')).next_float.should == 1.0
  end
  
  it "should interpret an array of strings correctly" do
    arr = ["a", "b", "c", "d"]
    Riddle::Client::Response.new(
      [arr.length].pack('N') + arr.collect { |str|
        [str.length].pack('N') + str
      }.join("")
    ).next_array.should == arr
  end
  
  it "should interpret an array of ints correctly" do
    arr = [1, 2, 3, 4]
    Riddle::Client::Response.new(
      [arr.length].pack('N') + arr.collect { |int|
        [int].pack('N')
      }.join("")
    ).next_int_array.should == arr
  end
  
  it "should reflect the length of the incoming data correctly" do
    data = [1, 2, 3, 4].pack('NNNN')
    Riddle::Client::Response.new(data).length.should == data.length
  end
  
  it "should handle a combination of strings and ints correctly" do
    data = [1, 3, 5, 1].pack('NNNN') + 'a' + [2, 4].pack('NN') + 'test'
    response = Riddle::Client::Response.new(data)
    response.next_int.should == 1
    response.next_int.should == 3
    response.next_int.should == 5
    response.next.should == 'a'
    response.next_int.should == 2
    response.next.should == 'test'
  end
  
  it "should handle a combination of strings, ints, floats and string arrays correctly" do
    data = [1, 2, 2].pack('NNN') + 'aa' + [2].pack('N') + 'bb' + [4].pack('N') +
      "word" + [7].pack('f').unpack('L*').pack('N') + [3, 2, 2, 2].pack('NNNN')
    response = Riddle::Client::Response.new(data)
    response.next_int.should == 1
    response.next_array.should == ['aa', 'bb']
    response.next.should == "word"
    response.next_float.should == 7
    response.next_int_array.should == [2, 2, 2]
  end
end