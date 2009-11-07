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
      @tagging = Tagging.create(:tagger => Freeform.find(@tag.id), :taggable => Work.first)
    end
    subject { @tagging }
    should_belong_to :tagger, :taggable
    should_validate_presence_of :tagger, :taggable
    should "delete its singleton, unwrangled tag on exit" do
      subject.destroy
      assert_raises(ActiveRecord::RecordNotFound) { @tag.reload }
    end
    should "not delete its tag if the tag has another tagging" do
      @work2 = create_work
      @work2.freeforms = [@tag]
      subject.destroy
      assert @tag.reload
    end
    should "not delete its tag if the tag has been wrangled canonical" do
      @tag.update_attribute(:canonical, true)
      subject.reload
      subject.destroy
      assert @tag.reload
    end
    should "not delete its tag if the tag has been wrangled synonym" do
      @tag.update_attribute(:merger_id, @tag.id)
      subject.reload
      subject.destroy
      assert @tag.reload
    end
  end

end
