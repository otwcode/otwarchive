require 'test_helper'

class PromptRestrictionTest < ActiveSupport::TestCase

  test "prompt_restriction_basics" do
    # the validation is done in the prompt class itself so this is not useful anymore :I
    
    # @char_tag = create_character(:canonical => true)
    # @freeform_tag = create_freeform(:canonical => true)
    # @fandom_tag1 = create_fandom(:canonical => true)
    # @fandom_tag2 = create_fandom(:canonical => true)
    # 
    # # set up the tagsets
    # @tagset1 = create_tag_set(:tags => [@fandom_tag1, @char_tag])
    # @tagset2 = create_tag_set(:tags => [@fandom_tag2, @freeform_tag])    
    # @tagset3 = create_tag_set(:tags => [@fandom_tag1, @char_tag, @freeform_tag])
    # 
    # @prompt_restriction = create_prompt_restriction(:tag_set => @tagset3, :fandom_num_required => 1, :fandom_num_allowed => 1,
    #                               :character_num_required => 1, :character_num_allowed => 3)
    # 
    # @prompt1 = create_prompt(:tag_set => @tagset1)    
    # @prompt2 = create_prompt(:tag_set => @tagset2)
    # 
    # assert @prompt_restriction.passes?(@prompt1)
    # assert !@prompt_restriction.passes?(@prompt2)

  end
  
end
