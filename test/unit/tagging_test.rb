require 'test_helper'

class TaggingTest < ActiveSupport::TestCase

  # before_destroy :delete_unused_tags
  context "a tagging" do
    setup do
      @work = Work.first || create_work
      @tag = create_freeform
      @mytagging = Tagging.create(:tagger => Freeform.find(@tag.id), :taggable => Work.first)
    end
    should_belong_to :tagger, :taggable
    should_validate_presence_of :tagger, :taggable
    should "delete its singleton, unwrangled tag on exit" do
      @mytagging.destroy
      assert_raises(ActiveRecord::RecordNotFound) { @tag.reload }
    end
    should "not delete its tag if the tag has another tagging" do
      @work2 = create_work
      @work2.freeforms = [@tag]
      @mytagging.destroy
      assert @tag.reload
    end
    should "not delete its tag if the tag has been wrangled canonical" do
      @tag.update_attribute(:canonical, true)
      @mytagging.reload
      @mytagging.destroy
      assert @tag.reload
    end
    should "not delete its tag if the tag has been wrangled synonym" do
      @tag.update_attribute(:merger_id, @tag.id)
      @mytagging.reload
      @mytagging.destroy
      assert @tag.reload
    end
  end

end
