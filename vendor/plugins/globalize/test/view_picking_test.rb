require File.dirname(__FILE__) + '/test_helper'

class ViewPickingTest < Test::Unit::TestCase
  include Globalize
  fixtures :globalize_languages, :globalize_countries

  class TestController < ActionView::Base
  end

  def setup
    Locale.set("en-US")
    @base_path = File.dirname(__FILE__) + '/views'
  end

  def test_first
    tc = TestController.new([@base_path])
    assert_match /English/, tc.render("test")
    assert_no_match /Hebrew/, tc.render("test")
    Locale.set("he-IL")
    assert_match /Hebrew/, tc.render("test")
    assert_no_match /English/, tc.render("test")
  end

  def test_non_full_path
    tc = TestController.new([@base_path])
    assert_match /English/, tc.render_file("#{@base_path}/test.rhtml", false)
  end

  def test_nil
    Locale.set(nil)
    tc = TestController.new([@base_path])
    assert_match /English/, tc.render("test")
    assert_no_match /Hebrew/, tc.render("test")
    Locale.set("he-IL")
    assert_match /Hebrew/, tc.render("test")
    assert_no_match /English/, tc.render("test")
  end

  def test_non_full_path_nil
    Locale.set(nil)
    tc = TestController.new([@base_path])
    assert_match /English/, tc.render_file("#{@base_path}/test.rhtml", false)
  end

end
