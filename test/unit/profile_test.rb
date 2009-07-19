require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < ActiveSupport::TestCase
  
  context "A profile" do
    setup do
      @profile = create_profile
    end
    should_belong_to :user
    
    context "with a location" do
      setup do
        @profile.location = random_word
      end
      should_ensure_length_in_range :location, (0..Profile::LOCATION_MAX), :long_message => /must be less/
    end
    
    context "with a title" do
      setup do
        @profile.title = random_sentence
      end
      should_ensure_length_in_range :title, (0..Profile::PROFILE_TITLE_MAX), :long_message => /must be less/  
    end
    
    context "with an about me section" do
      setup do
        @profile.about_me = random_paragraph
      end
      should_ensure_length_in_range :about_me, (0..Profile::ABOUT_ME_MAX), :long_message => /must be less/  
    end
  end
  
end
