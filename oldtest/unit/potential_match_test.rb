require 'test_helper'

class PotentialMatchTest < ActiveSupport::TestCase

  def test_generate
    num_signups = 6
    challenge_setup(num_signups) 
  
    # create potential matches
    PotentialMatch.generate(@collection)
    @collection.reload

    assert !@collection.potential_matches.empty?
  end
  
end
