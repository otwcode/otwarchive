
require "#{File.dirname(__FILE__)}/../test_helper"

class SpellTest < Test::Unit::TestCase

  def test_load_errors_are_rescued
    # XXX don't know how to test this sanely
  end
  
  def test_spelling
    if defined?(Aspell)
      assert_equal nil, Ultrasphinx::Spell.correct("correct words")
      assert_equal "garbled words", Ultrasphinx::Spell.correct("glarbled words")
    else
      STDERR.puts "No Aspell found"
    end
  end  

end