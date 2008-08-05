require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))

describe "ArrayConversions" do
  
  it "to 2d array" do
    assert_equal [[1, 1], [2, 2]], [1, 2].to_2d_array
    
    expected = [['A', 1], ['B', 2], ['C', 3]]
    assert_equal expected, { 'A' => 1, 'B' => 2, 'C' => 3 }.to_2d_array
    assert_equal expected, [['A', 1], ['B', 2], ['C', 3]].to_2d_array
  end
  
end