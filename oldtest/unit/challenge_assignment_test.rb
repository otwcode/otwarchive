require 'test_helper'

class ChallengeAssignmentTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  def initialize_potential_matches
    @num_signups = 6
    challenge_setup(@num_signups) 
  
    # create potential matches -- can't use PotentialMatch.generate because it runs 
    # assignments automatically 
    @collection.signups.each do |request_signup|
      PotentialMatch.generate_for_signup(@collection, request_signup)
    end
    @collection.reload
  end
    
  def test_assignment
    initialize_potential_matches
    assignment = ChallengeAssignment.assign_request!(@collection, @signups[0])
    assert assignment
    assert assignment.request_signup.assigned_as_request
    assert assignment.offer_signup.assigned_as_offer
  end

  def test_generation
    initialize_potential_matches
    ChallengeAssignment.generate(@collection)
    @collection.reload
    assert !@collection.assignments.empty?
    assert_equal @num_signups, @collection.assignments.size
  end

end




