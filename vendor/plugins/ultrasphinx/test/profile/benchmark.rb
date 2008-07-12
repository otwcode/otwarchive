#!/usr/bin/env ruby

require "#{File.dirname(__FILE__)}/../test_helper"
require 'benchmark'
require 'ruby-prof'

#def debugger; end
# require 'ruby-debug'

PROF = ENV['PROF']
TIMES = 50

$options = [{:query => 'seller'}]

#$search = Ultrasphinx::Search.new(*$options).run
#$sellers = Seller.find_all_by_id($search.results.select{|o| o.is_a? Seller}.map(&:id))
#$users = User.find_all_by_id($search.results.select{|o| o.is_a? User}.map(&:id))
#
## Mocha didn't work; don't know why
#class Riddle::Client
#  def query(*args); $search.response; end
#end
#class Seller
#  def self.find_all_by_id(*args); $sellers; end
#end
#class User
#  def self.find_all_by_id(*args); $users; end
#end

Benchmark.bm(20) do |x|
  x.report("simple") do 
    TIMES.times do
       Ultrasphinx::Search.new(*$options).run
    end
  end
  x.report("excerpt") do 
    RubyProf.start if PROF
    TIMES.times do
       Ultrasphinx::Search.new(*$options).excerpt
    end
    RubyProf::GraphPrinter.new(RubyProf.stop).print(STDOUT, 0) if PROF  
  end
end

