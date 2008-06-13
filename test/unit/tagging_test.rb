require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < ActiveSupport::TestCase
  fixtures :labels, :works
  def test_tag_with_and_tag_string
    work = create_work
    label = create_label(:name => 'some string')
    work.tag_with('some string')
    assert_equal 'some string', work.tag_string
    work.tag_with('new string')
    assert_equal 'new string', work.tag_string
    assert_equal [Label.find_by_name('new string')], work.tags
    assert_equal "Rodney McKay, Stargate SG-1, tentacles", Work.find(:first).tag_string
  end
  def test_characters_and_fandoms_and_freeforms
    assert_equal "Rodney McKay",  Work.find(:first).characters
    assert_equal 'Stargate SG-1',   Work.find(:first).fandoms
    assert_equal "tentacles",  Work.find(:first).freeforms
    assert_equal "John Sheppard, Rodney McKay", Label.find_by_name('Stargate Atlantis').characters
    assert_equal "Stargate Atlantis", Label.find_by_name('John Sheppard').fandoms
  end
end
