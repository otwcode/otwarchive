
require "#{File.dirname(__FILE__)}/../test_helper"

class ParserTest < Test::Unit::TestCase

  def setup
    @s = Ultrasphinx::Search.new
  end

  def test_valid_queries
    [
      'artichokes', 
      'artichokes',
      
      '  artichokes  ', 
      'artichokes',
      
      'artichoke heart', 
      'artichoke heart',
      
      '"artichoke hearts"', 
      '"artichoke hearts"',
      
      '  "artichoke hearts  " ', 
      '"artichoke hearts"',
      
      'artichoke AND hearts', 
      'artichoke hearts',
      
      'artichoke OR hearts', 
      'artichoke | hearts',
      
      'artichoke NOT heart', 
      'artichoke - heart',
  
      'artichoke and hearts', 
      'artichoke hearts',
      
      'artichoke or hearts', 
      'artichoke | hearts',
      
      'artichoke not heart', 
      'artichoke - heart',
      
      'title:artichoke', 
      '@title artichoke',
      
      'user:"john mose"', 
      '@user "john mose"',
      
      'artichoke OR rhubarb NOT heart user:"john mose"', 
      'artichoke | rhubarb - heart @user "john mose"',
      
      'title:artichoke hearts', 
      'hearts @title artichoke',
  
      'title:artichoke AND hearts', 
      'hearts @title artichoke',
      
      'title:artichoke NOT hearts', 
      'hearts - @title artichoke',
  
      'title:artichoke OR hearts', 
      'hearts | @title artichoke',
  
      'title:artichoke title:hearts', 
      '@title ( artichoke hearts )',
  
      'title:artichoke OR title:hearts', 
      '@title ( artichoke | hearts )',
  
      'title:artichoke NOT title:hearts "john mose" ', 
      '"john mose" @title ( artichoke - hearts )',
  
      '"john mose" AND title:artichoke dogs OR title:hearts cats', 
      '"john mose" dogs cats @title ( artichoke | hearts )',
      
      'board:england OR board:tristate',
      '@board ( england | tristate )',
      
      '(800) 555-LOVE',
      '(800) 555-LOVE',
      
      'Bend, OR',
      'Bend, OR',
  
      '"(traditional)"',
      '"traditional"',   
      
      'cuisine:"american (traditional"',
      '@cuisine "american traditional"',
      
      'title:cats OR user:john',
      '@title cats | @user john',
      
      'user:john OR title:cats',
      '@title cats | @user john',
      
    ].in_groups_of(2).each do |query, result|
      assert_equal result, @s.send(:parse, query)
    end
  end
  
  def test_invalid_queries
    [
      "\"", 
      "(", 
      ")", 
      "  \"  "
    ].each do |query|
      assert_raises(Ultrasphinx::Search::Parser::Error) do 
        @s.send(:parse, query)
      end
    end
  end

end

