require File.dirname(__FILE__) + '/test_helper'
require 'fileutils'

# TODO Test limit params
# TODO Test renaming
# TODO Examine contents of fixture and skeleton dump
class ArFixturesTest < Test::Unit::TestCase
  fixtures :beers, :drunkards, :beers_drunkards, :glasses
  include FileUtils

  def setup
    %w(db test/fixtures).each { |dir| mkdir_p File.join(RAILS_ROOT, dir) }
  end
  
  def test_dump_to_file
    %w(pilsner tripel).each {|name| Beer.create(:name => name) }
    
    assert_equal 2, Beer.count
    Beer.dump_to_file
    assert File.exist?(File.join(RAILS_ROOT, 'db', 'beers.yml'))
    
    Beer.destroy_all
    assert_equal 0, Beer.count
    Beer.load_from_file
    assert_equal 2, Beer.count
  end

  def test_load_from_file
    cp  File.join(RAILS_ROOT, 'fixtures', 'glasses.yml'), 
        File.join(RAILS_ROOT, 'db', 'glasses.yml')
    assert_equal 0, Glass.count
    Glass.load_from_file
    assert_equal 2, Glass.count
  end

  def test_to_fixture
    Beer.to_fixture
    assert File.exist?(File.join(RAILS_ROOT, 'test', 'fixtures', 'beers.yml'))
    assert File.exist?(File.join(RAILS_ROOT, 'test', 'fixtures', 'beers_drunkards.yml'))
  end
  
  def test_habtm_to_fixture
    Beer.habtm_to_fixture
    assert File.exist?(File.join(RAILS_ROOT, 'test', 'fixtures', 'beers_drunkards.yml'))
  end
  
  def test_to_skeleton
    Beer.to_skeleton
    assert File.exist?(File.join(RAILS_ROOT, 'test', 'fixtures', 'beers.yml'))
  end

  def teardown
    %w(db test).each { |dir| rm_rf File.join(RAILS_ROOT, dir) }    
  end
  
end
