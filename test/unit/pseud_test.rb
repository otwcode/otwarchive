require File.dirname(__FILE__) + '/../test_helper'

class PseudTest < ActiveSupport::TestCase
  context "A Pseud" do
    should_belong_to :user
    should_have_many :creatorships, :works, :chapters, :series
    should_validate_presence_of :name
    should_ensure_length_in_range :name, (1..40), :short_message => /too short/, :long_message => /too long/
    should_allow_values_for :name, "Good pseud", "good_pseud"
    should_not_allow_values_for :name, "bad!pseud", :message => /Pseuds can contain/
    should_ensure_length_in_range :description, (0..500), :long_message => /must be less/
  end
  def test_add_creations_to_default
    user = create_user
    new_pseud = create_pseud(:user => user)
    chapter = new_chapter(:authors => [new_pseud])
    work = create_work(:authors => [new_pseud], :chapters => [chapter])
    assert_equal [new_pseud], work.pseuds
    new_pseud.replace_me_with_default
    assert_equal [user.default_pseud], work.reload.pseuds
  end
end
