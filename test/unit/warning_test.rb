require File.dirname(__FILE__) + '/../test_helper'

class WarningTest < ActiveSupport::TestCase

  context "a warning Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Warning", Warning::NAME
    end
    should "have a required tags" do
      assert_equal 'None Of These Warnings Apply', Warning::NONE.name
      assert_equal 'Choose Not To Warn', Warning::DEFAULT.name
      assert_equal 'Extreme Violence', Warning::VIOLENCE.name
    end
  end
    
end
