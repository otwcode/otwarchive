require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  setup do
    create_tag
  end

  context "a Tag" do
    should_have_many :common_tags, :taggings
    should_have_many :works, :bookmarks, :external_works
    should_have_many :parents, :ambiguities, :filtered_works
    should_belong_to :merger, :fandom, :media
    should_require_attributes :name
    should_ensure_length_in_range :name, (1..ArchiveConfig.TAG_MAX), :long_message => /too long/, :short_message => /blank/
    should_allow_values_for :name, '"./?~!@#$%^&()_-+=', "1234567890", "spaces are not tag separators"
    should_not_allow_values_for :name, "commas, aren't allowed", :message => /can only/
    should_not_allow_values_for :name, "asterisks* aren't allowed", :message => /can only/
    should_not_allow_values_for :name, "angle brackets < aren't allowed", :message => /can only/
    should_not_allow_values_for :name, "angle brackets > aren't allowed", :message => /can only/

    should_allow_values_for :adult, true, false
    should_allow_values_for :canonical, true, false
    should_allow_values_for :wrangled, true, false
    
    context "with whitespace" do
      setup do
        @tag = create_tag(:name => "   whitespace'll   (be    stripped)    ")
      end
      should "be stripped" do
        assert_equal "whitespace'll (be stripped)", @tag.name
      end
    end
  end

  context "a tag and its mergers" do
    setup do
      @tag = create_pairing(:canonical => true)
      @pairing1 = create_pairing
      @pairing2 = create_pairing
      @character = create_character
      @pairing1.wrangle_merger(@tag)
      @pairing2.wrangle_merger(@tag)
      @tag.reload
    end
    should "have a many to one relationship" do
      assert_equal @tag, @pairing1.merger
      assert_equal @tag, @pairing2.merger
      assert_equal [@pairing1, @pairing2], @tag.mergers
    end
    should "be not able to be created from different types" do
      assert_nil @character.wrangle_merger(@tag)
      @tag.reload
      assert_equal [@pairing1, @pairing2], @tag.mergers
    end
    should "be canonical" do
      assert_nil @pairing1.wrangle_merger(@pairing2)
      assert_nil @tag.wrangle_merger(@pairing2)
    end
  end
  
  context "tags without a work" do
    setup { @tag = create_freeform }
    should "not be included in the cloud" do
       assert !Tag.for_tag_cloud.include?(@tag)
    end
  end
  context "tags with a work" do
    setup do
      @tag = create_freeform(:canonical => true)
      @work = create_work
      @work.update_attribute(:posted, true)
      @work.tags << @tag
    end
    should "be included in the cloud" do
       assert Tag.for_tag_cloud.include?(@tag)
    end
  end
  context "tags with a work which is not visible" do
    setup do
      @tag = create_freeform
      @work = create_work(:restricted => true)
      @work.update_attribute(:posted, true)
      @work.tags << @tag
    end
    should "not be included in the cloud" do
       assert !Tag.for_tag_cloud.include?(@tag)
    end
  end
  context "tags for tag cloud" do
    setup do
      @tag1 = create_freeform
      @tag2 = create_freeform
      @tag3 = create_freeform(:canonical => true)
      @tag4 = create_freeform
      @tag5 = create_character
      @tag1.wrangle_parent(@tag3)
      @tag2.wrangle_merger(@tag3)
      @work1=create_work
      @work1.update_attribute(:posted, true)
      @work2=create_work
      @work2.update_attribute(:posted, true)
      @work1.freeform_string = [@tag1, @tag2, @tag4].map(&:name).join(", ")
      @work2.freeform_string = [@tag1, @tag3].map(&:name).join(", ")
      @work2.character_string = @tag5.name
    end
    should "not include freeforms that have parents" do
       assert !Tag.for_tag_cloud.include?(@tag1)
    end
    should "not include freeforms that have been merged" do
       assert !Tag.for_tag_cloud.include?(@tag2)
    end
    should "include parent tags even if they do not appear on works" do
       assert Tag.for_tag_cloud.include?(@tag3)
    end
    should_eventually "include non-wrangled freeforms" do
       assert Tag.for_tag_cloud.include?(@tag4)
    end
    should "not include other kinds of tags" do
       assert !Tag.for_tag_cloud.include?(@tag5)
    end
  end
  
end
