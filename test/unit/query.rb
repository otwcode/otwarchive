require 'test_helper'

class QueryTest < ActiveSupport::TestCase
  # compare times as strings because the actual times
  # are off by milliseconds, and equality fails
  def test_time_from_string
    assert_equal 1.year.ago.to_s, Query.time_from_string("1", "year").to_s
    assert_equal 2.months.ago.to_s, Query.time_from_string("2", "months").to_s
    assert_equal 3.weeks.ago.to_s, Query.time_from_string("3", "weeks").to_s
    assert_equal 4.hours.ago.to_s, Query.time_from_string("4", "hours").to_s
    assert_raise RuntimeError do 
      Query.time_from_string("4", "minutes")
    end
  end

  def test_time_range
    assert Query.time_range("", "1-3", "years").include?(2.years.ago)
    assert Query.time_range("<", "3", "years").include?(2.years.ago)
    assert Query.time_range(">", "1", "years").include?(2.years.ago)
    assert_raise RuntimeError do
       Query.time_range("", "1", "years")
    end
  end

  def test_numerical_range
    assert Query.numerical_range("", "1-3").include?(2)
    assert Query.numerical_range("<", "3").include?(2)
    assert Query.numerical_range(">", "1").include?(100)
    assert_equal 2, Query.numerical_range("", "2")
  end

  def test_split_query
    assert_equal ["sidra", {}, []], Query.split_query({:text => "sidra"})
    assert_equal ["@language English", {}, []], Query.split_query({:language => "English"})
    assert_equal ["stone @author sidra", {}, []], Query.split_query({:text => "stone", :author => "sidra"})
    assert_equal ["@author sidra", {:word_count => 100}, []], Query.split_query({:words => "100", :author => "sidra"})
    assert_equal ["@title stone", {:hit_count => 0..99}, []], Query.split_query({:hits => "< 100", :title => "stone"})
    assert_equal ["sidra", {}, ["bad words format (ignored)"]], Query.split_query({:text => "sidra", :words => "long"})
    assert_equal ["@language Deutsch @tag harry -potter", {:word_count => 101..1000000}, []], Query.split_query({:tag => "harry -potter", :language => "Deutsch", :words => ">100"})
    assert_equal ["@(tag,indirect) harry @bookmarker painless_j", {}, []] , Query.split_query({:text => "(tag,indirect): harry", :bookmarker =>"painless_j"})
    assert_equal ["@(tag,indirect) harry", {:hit_count => 1001..1000000}, []] , Query.split_query({:text => "(tag,indirect): harry", :hits =>">1000"})
  end

  def test_standardize_query
    # basic text
    assert_equal ({:text => "astolat"}), Query.standardize(:text =>"astolat")
    # single field plus text
    assert_equal ({:text => "stone", :words => "100"}), Query.standardize(:text =>"stone words: 100")
    # two fields, no text
    assert_equal ({:text => "", :author => "astolat", :hits => "> 1000"}), Query.standardize(:text =>"author: astolat hits: > 1000")
    # text plus two fields (random spacing)
    assert_equal ({:text => "stone", :language => "English", :date => "3 - 6 years ago"}), Query.standardize(:text =>"stone date: 3 - 6 years ago language:English")
    # special characters in fields
    assert_equal ({:text => "", :title => "one | two", :tag => "harry -potter"}), Query.standardize(:text =>"title: one | two tag: harry -potter")
    # : in fields with quotes
    assert_equal ({:text => "", :title => '"something: the series"'}), Query.standardize(:text =>'title: "something: the series"')
    # : in text
    assert_equal ({:text => "something: the series"}), Query.standardize(:text =>"something: the series")
    # : in fields 
    assert_equal ({:text => "", :tag => "community: something"}), Query.standardize(:text =>"tag: community: something")
    # : in fields and text 
    assert_equal ({:text => "boo:hiss", :tag => "community: something"}), Query.standardize(:text =>"boo:hiss tag: community: something")
    # preserve parenthesis
    assert_equal ({:text => "(tag,indirect): harry"}), Query.standardize(:text => "(tag,indirect): harry")
    # preserve parenthesis multiple fields
    assert_equal ({:text => "(tag,indirect,bookmarker): harry"}), Query.standardize(:text => "(tag,indirect,bookmarker): harry")
    # preserve parenthesis but allow other fields after as well
    assert_equal ({:text => "(tag,indirect): harry", :bookmarker =>"painless_j"}), Query.standardize(:text => "(tag,indirect): harry  bookmarker:painless_j")
    # preserve parenthesis but allow other fields before as well
    assert_equal ({:text => "(tag,indirect): harry", :hits =>">1"}), Query.standardize(:text => "hits: >1 (tag,indirect): harry")
  end
end
