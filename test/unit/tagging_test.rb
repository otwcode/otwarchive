require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < ActiveSupport::TestCase
  setup do
    create_work
  end

  # before_destroy :delete_unused_tags
  context "a tagging" do
    setup do
      @work = Work.first || create_work
      @tag = create_freeform
      @tagging = Tagging.create(:tag => Freeform.find(@tag.id), :taggable => Work.first)
    end
    should_belong_to :tag, :taggable
    should_require_attributes :tag, :taggable
    should "delete its singleton, unwrangled tag on exit" do
      @tagging.destroy
      assert_raises(ActiveRecord::RecordNotFound) { @tag.reload } 
    end
    should "not delete its tag if the tag has another tagging" do
      @work2 = create_work
      @work2.freeforms = [@tag]
      @tagging.destroy
      assert @tag.reload
    end
    should "not delete its tag if the tag has been wrangled (is canonical)" do
      @tag.update_attribute(:canonical, true)
      @tagging.reload
      @tagging.destroy
      assert @tag.reload
    end
    should "not delete its tag if the tag has been wrangled (is banned)" do
      @tag.update_attribute(:banned, true)
      @tagging.reload
      @tagging.destroy
      assert @tag.reload
    end
    should "not delete its tag if the tag has been wrangled (has a synonym)" do
      # can't test this, as a tagging with a tag with a synonym should never exist
    end
  end

  # before_create :check_for_synonyms
  context "a tagging using a tag without synonyms" do
    setup do
      @tag = create_tag
      @tagging = create_tagging(:tag => @tag, :taggable => Work.first)
    end
    should "use the original tag" do
      assert_equal @tag, @tagging.tag
    end
  end
  context "a tagging using a tag with a synonym" do
    setup do
      @tag = create_tag
      @canonical = create_tag(:canonical => true, :type => @tag.type)
      assert @tag.synonym = @canonical
      @tagging = Tagging.create(:tag => Tag.find(@tag.id), :taggable => Work.first)
    end
    should "use the synonym tag" do
      assert_equal Tag.find(@canonical), Tagging.find(@tagging.id).tag
    end
  end
  
  context "a new pairing tag added to a work" do
    setup do
      @work = create_work
      @work.pairing_string = "first/second"
    end
    should "get the fandom of the work" do
      assert_equal @work.fandoms, [Pairing.find_by_name("first/second").fandom]
    end
  end

  context "a new character tag added to a work" do
    setup do
      @work = create_work
      @work.character_string = "new guy"
    end
    should "get the fandom of the work" do
      assert_equal @work.fandoms, [Character.find_by_name("new guy").fandom]
    end
  end

end
