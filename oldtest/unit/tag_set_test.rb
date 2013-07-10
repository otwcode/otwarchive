require 'test_helper'

class TagSetTest < ActiveSupport::TestCase
  context "a TagSet" do
    should_have_many :set_taggings, :tags
  end
  
  context "a new TagSet" do
    setup do
      @tag = create_tag(:canonical => true)
      @tagset = TagSet.new
      @tagset.tags << @tag
      @tagset.save
      @set_tagging = @tagset.set_taggings.first
    end
    should "allow only canonical tags" do
      assert @tagset.valid?
      @tag2 = create_tag
      @tagset.tags << @tag2
      assert !@tagset.valid?
    end
    should "destroy the associated set taggings when destroyed" do
      @tagset.destroy
      assert_raises(ActiveRecord::RecordNotFound) { @set_tagging.reload }
    end
  end

  test "tag set basics" do
    @tagset1 = TagSet.new
    @tagset2 = TagSet.new
    @tagset3 = TagSet.new

    # set up some canonical tags
    @freeform_tag = create_freeform(:canonical => true)
    @char_tag = create_character(:canonical => true)
    @fandom_tag1 = create_fandom(:canonical => true)
    @fandom_tag2 = create_fandom(:canonical => true)
    
    # set up the tagsets
    @tagset1.tags << @fandom_tag1
    @tagset1.tags << @char_tag
    assert @tagset1.valid?
    @tagset1.save
    
    @tagset2.tags << @fandom_tag2
    @tagset2.tags << @freeform_tag
    assert @tagset2.valid?
    @tagset2.save
    
    # shouldn't have any matches at all here
    assert @tagset1.no_match?(@tagset2)
    assert !(@tagset1 == @tagset2)
    assert !@tagset1.partial_match?(@tagset2)
    assert !@tagset1.exact_match?(@tagset2, "Fandom")
    assert !@tagset1.partial_match?(@tagset2, "Fandom")

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
    assert @tagset1.exact_match?(@tagset3, "Fandom")
    assert !@tagset2.exact_match?(@tagset3, "Fandom")
    
    assert @tagset3.is_superset_of?(@tagset1)
    assert @tagset1.is_subset_of?(@tagset3)
    assert !@tagset1.is_superset_of?(@tagset3)
    assert !@tagset3.is_subset_of?(@tagset1)    
    
    assert @tagset1.matching_tags(@tagset3).size == 2
    assert @tagset2.matching_tags(@tagset3).size == 1

    # now get order of matches -- tagset1 should come first
    matched_sets = TagSet.matching(@tagset3)
    assert (matched_sets.length == 2)
    assert matched_sets[0] == @tagset1
    assert matched_sets[1] == @tagset2
    
    # test addition/subtraction
    assert (@tagset1 + @tagset2).tags = @tagset1.tags + @tagset2.tags
    assert (@tagset1 - @tagset2).tags = @tagset1.tags - @tagset2.tags
    assert (@tagset1 + @tagset3).tags = @tagset1.tags + @tagset3.tags
    assert (@tagset1 - @tagset3).tags = @tagset1.tags - @tagset3.tags
  end
  
  test "tagnames functions" do
    @tagset = TagSet.new
    @taglist = []
    %w(fandom character relationship rating warning category freeform).each do |type| 
      eval("#{type}_tag = create_#{type}(:canonical => true)")
      eval("@taglist << #{type}_tag")
      eval("@tagset.#{type}_tagnames = #{type}_tag.name")
      assert @tagset.valid?
      assert eval("@tagset.#{type}_taglist") == eval("[#{type}_tag]")
    end
    assert @tagset.save
    assert @tagset.reload
    assert (@tagset.tags - @taglist).empty?
  end  
      
end
