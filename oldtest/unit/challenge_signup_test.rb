require 'test_helper'

class ChallengeSignupTest < ActiveSupport::TestCase

  def test_match
    @collection = create_collection(:challenge => create_gift_exchange)
    @collection.challenge.potential_match_settings = create_potential_match_settings(:num_required_prompts => 1, :num_required_fandoms => 1)

    # create a whole mess of fandom tags
    @fandom_tags = []
    5.times {@fandom_tags << create_fandom(:canonical => true)}
        
    # use overlapping tags, should match
    @tagset1a = create_tag_set(:tags => @fandom_tags[0..3])
    @tagset1b = create_tag_set(:tags => @fandom_tags[2..4])
    
    @request = create_request(:collection => @collection, :tag_set => @tagset1a)
    @offer = create_offer(:collection => @collection, :tag_set => @tagset1b)

    @request_signup = create_challenge_signup(:collection => @collection, :requests => [@request], :offers => [@offer])
    @offer_signup = create_challenge_signup(:collection => @collection, :requests => [@request], :offers => [@offer])
    
    # we should get a valid potential match
    pm = @request_signup.match(@offer_signup)
    assert !pm.nil?
    assert pm.valid?
    assert pm.save

    # create second offer with different tag, shouldn't match
    @tagset2 = create_tag_set(:tags => [create_fandom(:canonical => true)])
    @offer2 = create_offer(:collection => @collection, :tag_set => @tagset2)

    @offer_signup2 = create_challenge_signup(:collection => @collection, :requests => [@request], :offers => [@offer2])

    # no match
    pm = @request_signup.match(@offer_signup2)
    assert pm.nil?

  end


  def test_optional_tag_set_match
    @collection = create_collection(:challenge => create_gift_exchange)
    
    # create a whole mess of fandom tags
    @fandom_tags = []
    5.times {@fandom_tags << create_fandom(:canonical => true)}
        
    # no matching tags
    @tagset1a = create_tag_set(:tags => @fandom_tags[0..1])
    @tagset1b = create_tag_set(:tags => @fandom_tags[3..4])
    
    # overlapping tag only in optional tagsets
    @tagset_1a_opt = create_tag_set(:tags => [@fandom_tags[2]])
    @tagset_1b_opt = create_tag_set(:tags => [@fandom_tags[2]])
    @request = create_request(:collection => @collection, :tag_set => @tagset1a, :optional_tag_set => @tagset_1a_opt)
    @offer = create_offer(:collection => @collection, :tag_set => @tagset1b, :optional_tag_set => @tagset_1b_opt)
    @request_signup = create_challenge_signup(:collection => @collection, :requests => [@request], :offers => [@offer])
    @offer_signup = create_challenge_signup(:collection => @collection, :requests => [@request], :offers => [@offer])
    
    @collection.challenge.potential_match_settings = create_potential_match_settings(:num_required_prompts => 1, :num_required_fandoms => 1, :include_optional_fandoms => false)
    # should not match
    pm = @request_signup.match(@offer_signup)
    assert pm.nil?
    
    # should match
    @collection.challenge.potential_match_settings = create_potential_match_settings(:num_required_prompts => 1, :num_required_fandoms => 1, :include_optional_fandoms => true)
    pm = @request_signup.match(@offer_signup)
    assert !pm.nil?
    assert pm.valid?
    assert pm.save
  end
    
end
