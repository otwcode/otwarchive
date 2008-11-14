require File.dirname(__FILE__) + '/../test_helper'

class PairingTest < ActiveSupport::TestCase

  context "a pairing Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags, :characters
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Pairing", Pairing::NAME
    end
  end
    
  context "a new pairing tag" do
    setup do
      @pairing = Pairing.create(:name => "first/second")
    end
    should "have access to its characters" do
      assert @pairing.characters.include?(Character.find_by_name("first"))
      assert @pairing.characters.include?(Character.find_by_name("second"))
    end
    context "which is made canonical" do
      setup do
        @pairing.update_attribute(:canonical, true)
      end
      should "update its characters to be canonical" do
        assert Character.find_by_name("first").canonical?
        assert Character.find_by_name("second").canonical?
      end
    end
  end

  context "a new canonical pairing tag" do
    setup do
      @pairing = Pairing.create(:name => "alpha/beta", :canonical => true)
    end
    should "have canonical characters" do
      assert_equal [true, true], @pairing.characters.map(&:canonical)
    end
  end

  context "a new threesome pairing tag" do
    setup do
      @pairing = Pairing.create(:name => "first/second/third")
    end
    should "have three characters" do
      assert_equal 3, @pairing.characters.size
    end
  end

  context "a work with a new pairing" do
    setup do
      @work = create_work
      @work.pairing_string = "firstly/secondly"
    end
    should "get the fandom of the work" do
      assert_equal @work.fandoms, [Pairing.find_by_name("firstly/secondly").fandom]
    end
  end
  
end
