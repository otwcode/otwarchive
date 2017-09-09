require 'spec_helper'
require 'rake'

class PassingJob
  def self.perform(string)
    #puts "working correctly: " + string
  end
end
class FailingJob
  def self.perform(string)
    work = Work.find_by(id: 1)
    work.destroy if work
    Work.find 1
  end
end
class BrokenJob
  def self.perform(string)
    Work.no_such_method
  end
end

describe "resque rake tasks" do
  before do
    (Resque::Failure.count-1).downto(0).each { |i| Resque::Failure.remove(i) }
    @rake = Rake.application
    begin
      @rake.init
    rescue SystemExit
    end
    @rake.load_rakefile
    @worker = Resque::Worker.new(:tests)
  end

  describe "rake resque:run_failures" do
    before do
      @task_name = "resque:run_failures"
    end
    it "should have 'environment' as a prereq" do
      expect(@rake[@task_name].prerequisites).to include("environment")
    end
    it "should clear out passing jobs" do
      Resque::Failure.create(exception: Exception.new(ActiveRecord::RecordNotFound),
                             worker: @worker,
                             queue: 'tests',
                             payload: { 'class' => 'PassingJob', 'args' => 'retry found me' })
      assert_equal 1, Resque::Failure.count
      @rake[@task_name].invoke

      assert_equal 0, Resque::Failure.count
    end
    it "should clear out failing jobs if they're RecordNotFound" do
      Resque::Failure.create(exception: Exception.new(ActiveRecord::RecordNotFound),
                             worker: @worker,
                             queue: 'tests',
                             payload: { 'class' => 'FailingJob', 'args' => 'still missing on retry' })
      assert_equal 1, Resque::Failure.count
      @rake[@task_name].execute

      assert_equal 0, Resque::Failure.count
    end
    it "should not clear out failing jobs if they're not RecordNotFound" do
      Resque::Failure.create(exception: Exception.new(NoMethodError),
                             worker: @worker,
                             queue: 'tests',
                             payload: { 'class' => 'BrokenJob', 'args' => 'will never work' })
      assert_equal 1, Resque::Failure.count
      @rake[@task_name].execute rescue nil

      assert_equal 1, Resque::Failure.count

      # clean up
      Resque::Failure.remove(0)
    end
  end
end
