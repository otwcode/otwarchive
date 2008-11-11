require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  setup do
    create_tag
  end

  context "a Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags
    should_require_attributes :name
    should_ensure_length_in_range :name, (1..ArchiveConfig.TAG_MAX), :long_message => /too long/, :short_message => /blank/
    should_allow_values_for :name, '"./?~!@#$%^&()_-+=', "1234567890", "spaces are not tag separators"
    should_not_allow_values_for :name, "commas, aren't allowed", :message => /can only/
    should_not_allow_values_for :name, "asterisks* aren't allowed", :message => /can only/
    should_not_allow_values_for :name, "angle brackets < aren't allowed", :message => /can only/
    should_not_allow_values_for :name, "angle brackets > aren't allowed", :message => /can only/

    should_allow_values_for :adult, true, false
    should_allow_values_for :banned, true, false
    should_allow_values_for :canonical, true, false
    
    context "with whitespace" do
      setup do
        @tag = create_tag(:name => "   whitespace'll   (be    stripped)    ")
      end
      should "be stripped" do
        assert_equal "whitespace'll (be stripped)", @tag.name
      end
    end
  end

  context "a canonical tag" do
    setup do
      @tag = create_tag(:canonical => false, :type => 'Freeform')
      @tag2 = create_tag(:canonical => false, :type => 'Freeform')
      @tag3 = create_tag(:canonical => false, :type => 'Fandom')
      @canonical = create_tag(:canonical => true, :type => 'Freeform')
      @tag.synonym=@canonical
      @tag2.synonym=@canonical
      @tag3.synonym=@canonical
    end
    should "should be able to have many noncanonical tags as synonyms" do
      assert_equal Tag.find(@canonical.id), Tag.find(@tag.id).synonym
      assert_equal Tag.find(@canonical.id), Tag.find(@tag2.id).synonym
      assert @canonical.synonyms.include?(Tag.find(@tag.id))
      assert @canonical.synonyms.include?(Tag.find(@tag2.id))
    end
    should "be able to have tags of a different type as a synonym" do
      assert_equal Tag.find(@canonical.id), Tag.find(@tag3.id).synonym
      assert Tag.find(@canonical.id).synonyms.include?(Tag.find(@tag3.id))
    end
  end
  context "a non-canonical tag" do
    setup do
      @tag = create_tag(:canonical => false, :type => 'Freeform')
      @tag2 = create_tag(:canonical => false, :type => 'Freeform')
      @work = create_work
      @work.tags << @tag
      @canonical = create_tag(:canonical => true, :type => 'Freeform')
   end
    should "should not be able to be a synonym" do
      @tag2.synonym=@tag
      @tag2.reload
      assert_nil @tag2.synonym
    end
    should "reassign its work" do
      @tag.synonym=@canonical
      @work.reload
      assert_equal [Tag.find(@canonical.id)], @work.freeforms
    end
  end
  
  context "tags by_category" do
    should "find tags in a single category" do
      assert_match "Explicit", Tag.by_category("Rating").map(&:name).join
    end
    should "find tags in multiple categories" do
      assert_match "Explicit", Tag.by_category("Rating", "Warning").map(&:name).join
      assert_match "Violence", Tag.by_category(["Rating", "Warning"]).map(&:name).join
    end
  end
  
end
