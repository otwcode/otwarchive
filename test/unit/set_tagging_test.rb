require 'test_helper'

class SetTaggingTest < ActiveSupport::TestCase
  context "a set tagging" do
    should_belong_to :tag_set, :tag
  end
end
