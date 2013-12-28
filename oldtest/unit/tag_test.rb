require 'test_helper'

class TagTest < ActiveSupport::TestCase
  context "a Tag" do
    should_have_many :common_taggings, :taggings
    should_have_many :works, :bookmarks, :external_works
    should_have_many :parents, :filtered_works
    should_belong_to :merger
    should_validate_presence_of :name
    should_ensure_length_in_range :name, (1..ArchiveConfig.TAG_MAX), :long_message => /too long/, :short_message => /blank/
    should_allow_values_for :name, '"./?~!@#$&()_-+:;[]|', "1234567890", "spaces aren't tag separators"
    should_not_allow_values_for :name, "commas, aren't allowed", :message => /can not include/
    should_not_allow_values_for :name, "asterisks* aren't allowed", :message => /can not include/
    should_not_allow_values_for :name, "angle brackets < aren't allowed", :message => /can not include/
    should_not_allow_values_for :name, "angle brackets > aren't allowed", :message => /can not include/
    should_not_allow_values_for :name, "carats ^ aren't allowed", :message => /can not include/
    should_not_allow_values_for :name, "curly braces { aren't allowed", :message => /can not include/
    should_not_allow_values_for :name, "curly braces } aren't allowed", :message => /can not include/
    should_not_allow_values_for :name, "equal signs = aren't allowed", :message => /can not include/
    should_not_allow_values_for :name, "back ticks ` aren't allowed", :message => /can not include/
    should_not_allow_values_for :name, 'back slashes \ are not allowed', :message => /can not include/
    should_not_allow_values_for :name, 'percent signs % are not allowed', :message => /can not include/
    
    should_allow_values_for :adult, true, false
    should_allow_values_for :canonical, true, false

    context "with whitespace" do
      setup do
        @name = random_tag_name(30)
        @tag = create_tag(:name => "   " + @name + "    a    " )
      end
      should "be stripped" do
        assert_equal @name + " a", @tag.name
      end
    end
  end

  context "tags on find_or_create_by_name" do
    setup do
      @string = "This tag should not yet exist"
      @tag = Character.find_or_create_by_name(@string)
      assert @tag2 = Fandom.find_or_create_by_name(@string)
    end
    should "be created" do
      assert @tag.is_a?(Character)
    end
    should "be found if it's the same class" do
      assert_equal @tag, Character.find_or_create_by_name(@tag.name)
    end
    should "be created with suffix if they're a different class" do
      assert_not_equal @tag, @tag2
      assert_equal @string + " - Fandom", @tag2.name
    end
  end

  context "tags with different capitalization" do
    setup do
      @tag1 = Tag.find_or_create_by_name("A tag")
      @tag2 = Tag.find_or_create_by_name("b tag")
      @tag3 = Tag.find_or_create_by_name("C tag")
    end
    should "sort case insensitive" do
      assert_equal [@tag1, @tag2, @tag3], [@tag3, @tag1, @tag2].sort
    end
  end
end
