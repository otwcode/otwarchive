require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  setup do
    create_tag
  end

  context "a Tag" do
    should_have_many :common_taggings, :taggings
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

  context "tags without a fandom" do
    setup { @tag = create_freeform }
    should "not be included in the cloud" do
       assert !Tag.for_tag_cloud.include?(@tag)
    end
  end
  context "tags with a fandom" do
    setup do
      @tag = create_freeform
      @tag.add_fandom(Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME).id)
    end
    should "be included in the cloud" do
       assert Tag.for_tag_cloud.include?(@tag)
    end
    context "which have been merged" do
      setup do
        merger = create_freeform(:canonical => true)
        @tag.wrangle_merger(merger)
      end
      should "not be included in the cloud" do
        assert !Tag.for_tag_cloud.include?(@tag)
      end
    end
  end
  context "tags with a work which is not visible" do
    setup do
      @tag = create_freeform
      @work = create_work(:restricted => true)
      @work.update_attribute(:posted, true)
      @work.tags << @tag
    end
    should_eventually "not be included in the cloud" do
       assert !Tag.for_tag_cloud.include?(@tag)
    end
  end
  context "tags for tag cloud" do
    setup do
      @tag = create_character
      @tag.add_fandom(Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME).id)
    end
    should "not include other kinds of tags" do
       assert !Tag.for_tag_cloud.include?(@tag)
    end
  end

end
