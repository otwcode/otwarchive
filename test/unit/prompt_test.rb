require 'test_helper'

class PromptTest < ActiveSupport::TestCase

  def test_match
    @collection = create_collection
    @collection.challenge = create_gift_exchange
    @collection.challenge.potential_match_settings = create_potential_match_settings

    # create a whole mess of fandom tags
    @fandom_tags = []
    5.times {@fandom_tags << create_fandom(:canonical => true)}
        
    # use overlapping tags, should match
    @tagset1a = create_tag_set(:tags => @fandom_tags[0..3])
    @tagset1b = create_tag_set(:tags => @fandom_tags[2..4])

    @request = create_request(:collection => @collection, :tag_set => @tagset1a)
    @offer = create_offer(:collection => @collection, :tag_set => @tagset1b)
    
    ppm = @request.match(@offer)
    assert !ppm.nil?
    assert ppm.valid?

    # create with random tagset, won't match
    @offer2 = create_offer(:collection => @collection)
    ppm = @request.match(@offer2)
    assert ppm.nil?

  end

end
