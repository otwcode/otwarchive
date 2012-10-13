require 'test_helper'

class ExternalAuthorNameTest < ActiveSupport::TestCase

  context "an external author name" do
    should_belong_to :external_author
    should_validate_presence_of :name
    should_ensure_length_in_range :name, (ExternalAuthorName::NAME_LENGTH_MIN..ExternalAuthorName::NAME_LENGTH_MAX), :short_message => /too short/, :long_message => /too long/
    should_allow_values_for :name, "Good name", "good_name"
    should_not_allow_values_for :name, "bad!name", :message => /can contain/
    should_not_allow_values_for :name, " ", :message => /must contain/
  end
  
end
