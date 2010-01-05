require 'test_helper'

class TagSetTest < ActiveSupport::TestCase
  context "a TagSet" do
    should_have_many :set_taggings, :tags
    
    context "on destroy" do
      setup do
        @tag = create_freeform
        @tagset = TagSet.new
        @tagset.tags << @tag
        @tagset.save
        @set_tagging = @tagset.set_taggings.first
      end
      should "destroy the associated set taggings when destroyed" do
        @tagset.destroy
        assert_raises(ActiveRecord::RecordNotFound) { @set_tagging.reload }
      end
    end
  end

  test "tag set basics" do
    @tagset1 = TagSet.new
    @tagset2 = TagSet.new
    @tagset3 = TagSet.new
    
    @char_tag = Character.find_or_create_by_name(String.random)
    @freeform_tag = create_freeform
    @fandom_tag1 = Fandom.find_or_create_by_name(String.random)
    @fandom_tag2 = Fandom.find_or_create_by_name(String.random)
    
    # set up the tagsets
    @tagset1.tags << @fandom_tag1
    @tagset1.tags << @char_tag
    @tagset1.save
    
    @tagset2.tags << @fandom_tag2
    @tagset2.tags << @freeform_tag
    @tagset2.save
    
    # shouldn't have any matches at all here
    assert @tagset1.no_match?(@tagset2)
    assert !(@tagset1 == @tagset2)
    assert !@tagset1.partial_match?(@tagset2)
    assert !@tagset1.match_with_type?(@tagset2, "Fandom")
    assert !@tagset1.partial_match_with_type?(@tagset2, "Fandom")

    # now set up some matches
    @tagset3.tags << @fandom_tag1
    @tagset3.tags << @char_tag
    @tagset3.tags << @freeform_tag
    @tagset3.save
    
    assert !@tagset1.no_match?(@tagset3)
    assert !@tagset2.no_match?(@tagset3)
    assert !(@tagset1 == @tagset3)
    assert !(@tagset2 == @tagset3)
    assert @tagset1.partial_match?(@tagset3)
    assert @tagset2.partial_match?(@tagset3)
    assert @tagset1.match_with_type?(@tagset3, "Fandom")
    assert !@tagset2.match_with_type?(@tagset3, "Fandom")
    
    assert @tagset1.matching_tags(@tagset3).size == 2
    assert @tagset2.matching_tags(@tagset3).size == 1

    # now get order of matches -- tagset1 should come first
    matched_sets = TagSet.matching(@tagset3)
    assert (matched_sets.length == 2)
    assert matched_sets[0] == @tagset1
    assert matched_sets[1] == @tagset2
  end
end
