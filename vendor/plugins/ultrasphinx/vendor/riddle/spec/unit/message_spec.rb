require 'spec/spec_helper'

describe Riddle::Client::Message do
  it "should start with an empty string" do
    Riddle::Client::Message.new.to_s.should == ""
  end
  
  it "should append raw data correctly" do
    data = [1, 2, 3].pack('NNN')
    message = Riddle::Client::Message.new
    message.append data
    message.to_s.should == data
  end
  
  it "should append strings correctly - with length first" do
    str = "something to test with"
    message = Riddle::Client::Message.new
    message.append_string str
    message.to_s.should == [str.length].pack('N') + str
  end
  
  it "should append integers correctly - packed with N" do
    message = Riddle::Client::Message.new
    message.append_int 234
    message.to_s.should == [234].pack('N')
  end
  
  it "should append floats correctly - packed with f" do
    message = Riddle::Client::Message.new
    message.append_float 1.4
    message.to_s.should == [1.4].pack('f').unpack('L*').pack('N')
  end
  
  it "should append a collection of integers correctly" do
    message = Riddle::Client::Message.new
    message.append_ints 1, 2, 3, 4
    message.to_s.should == [1, 2, 3, 4].pack('NNNN')
  end
  
  it "should append a collection of floats correctly" do
    message = Riddle::Client::Message.new
    message.append_floats 1.0, 1.1, 1.2, 1.3
    message.to_s.should == [1.0, 1.1, 1.2, 1.3].pack('ffff').unpack('L*L*L*L*').pack('NNNN')
  end
  
  it "should append an array of strings correctly" do
    arr = ["a", "bb", "ccc"]
    message = Riddle::Client::Message.new
    message.append_array arr
    message.to_s.should == [3, 1].pack('NN') + "a" + [2].pack('N') + "bb" +
      [3].pack('N') + "ccc"
  end
  
  it "should append a variety of objects correctly" do
    message = Riddle::Client::Message.new
    message.append_int 4
    message.append_string "test"
    message.append_array ["one", "two"]
    message.append_floats 1.5, 1.7
    message.to_s.should == [4, 4].pack('NN') + "test" + [2, 3].pack('NN') +
      "one" + [3].pack('N') + "two" + [1.5, 1.7].pack('ff').unpack('L*L*').pack('NN')
  end
end