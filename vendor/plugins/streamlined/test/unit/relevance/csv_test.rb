require File.dirname(__FILE__) + '/../../test_helper'
  
describe "Enumerable" do
  
  it "array header" do
    assert_equal("Upper,Normal\nA,a\nB,b\n", ['a','b'].to_csv([:upcase, :to_str], :header=>["Upper", "Normal"]))
  end
  
  it "array header with different separator" do
    assert_equal("Upper;Normal\nA;a\nB;b\n", ['a','b'].to_csv([:upcase, :to_str], {:header=>["Upper", "Normal"], :separator=>";"} ))
  end
  
  it "no header" do
    assert_equal("A,a\nB,b\n", ['a','b'].to_csv([:upcase, :to_str], :header=>false))
  end
  
  it "no header with different separator" do
    assert_equal("A;a\nB;b\n", ['a','b'].to_csv([:upcase, :to_str], {:header=>false, :separator=>";"} ))
  end
  
  it "boolean header" do
    assert_equal("upcase,to_str\nA,a\nB,b\n", ['a','b'].to_csv([:upcase, :to_str], :header=>true))
  end

  it "boolean header with different separator" do
    assert_equal("upcase;to_str\nA;a\nB;b\n", ['a','b'].to_csv([:upcase, :to_str], {:header=>true, :separator=>";"} ))
  end


end