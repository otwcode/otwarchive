require File.dirname(__FILE__) + '/../test_helper'


class UserTest < ActiveSupport::TestCase

  fixtures :users, :pseuds

  def setup
    @jossfan = users(:jossfan)
    @dsfan = users(:dsfan)
    @mary = users(:mary)
    @lurker = users(:lurker)
  end

  def test_truth
    assert true
  end

  def test_user_has_pseud_with_simple_names
    assert @jossfan.has_pseud?("buffy"), "@jossfan doesn't know he has the pseud \"buffy\""
    assert @jossfan.has_pseud?(@jossfan.pseuds.first.name), "@jossfan doesn't know he has a pseud he should have"
    assert !@jossfan.has_pseud?("sheppard"), "@jossfan think he has a pseud that he doesn't own"
  end

  def test_user_has_pseud_with_spaces
    @jossfans_buffy_pseud = pseuds(:buffy)
    @marys_marie_pseud = pseuds(:marie)
    assert @mary.has_pseud?("mary sue"), "@mary doesn't know about her mary sue pseud"
    assert @mary.has_pseud?(@marys_marie_pseud.name), "@mary doesn't know about her marie pseud"
    assert !@mary.has_pseud?(@jossfans_buffy_pseud.name), "@mary thinks buffy is one of her pseuds"
  end

  def test_user_default_pseud_for_users_with_pseuds
    marys_default_pseud = pseuds(:mary_sue)
    assert_equal marys_default_pseud, @mary.default_pseud
  end

  def no_test_user_default_pseud_for_users_without_additional_pseuds

  end
end
