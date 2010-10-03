require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  
  context "A profile" do
    setup do
      assert create_profile
    end
    should_belong_to :user
  end  
    
  context "with a location" do
    setup do
      assert create_profile(:location => random_word)
    end
    should_ensure_length_in_range :location, (0..Profile::LOCATION_MAX), :long_message => /must be less/
  end
    
  context "with a title" do
    setup do
      assert create_profile(:title => random_sentence)
    end
    should_ensure_length_in_range :title, (0..Profile::PROFILE_TITLE_MAX), :long_message => /must be less/  
  end
    
  context "with an about me section" do
    setup do
      assert create_profile(:about_me => random_paragraph)
    end
    should_ensure_length_in_range :about_me, (0..Profile::ABOUT_ME_MAX), :long_message => /must be less/  
  end
  
end
