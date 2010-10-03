require 'test_helper'

class FilterTaggingTest < ActiveSupport::TestCase
  setup do
    create_work
  end

  context "a filter tagging" do
    setup do
      @work = Work.first || create_work
      @fandom = create_fandom(:canonical => true)
      @fandom2 = create_fandom
    end
    should "be created when a work is tagged with a canonical tag" do
      @work.fandom_string = @fandom.name
      @work.save
      assert @work.filters.include?(@fandom)
    end
    should "not be created when a work is tagged with a non-canonical tag" do
      @work.fandom_string = @fandom2.name
      @work.save
      assert !@work.filters.include?(@fandom2)      
    end
    should "be created when a work is tagged with a non-canonical tag that has a canonical merger" do
      @fandom2.update_attribute(:merger_id, @fandom.id)
      @work.fandom_string = @fandom2.name
      @work.save
      assert @work.filters.include?(@fandom)      
    end
    should "be removed when a work is no longer tagged with a given tag" do
      @fandom2.update_attribute(:canonical, true)
      @work.fandom_string = @fandom2.name
      assert @work.filters.include?(@fandom2)
      assert !@work.filters.include?(@fandom)      
    end    
  end
end