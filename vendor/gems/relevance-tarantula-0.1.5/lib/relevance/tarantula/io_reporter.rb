class Relevance::Tarantula::IOReporter
  
  include Relevance::Tarantula
  attr_accessor :io, :results
  delegate :successes, :failures, :to => :results
  
  IOResultOverview = Struct.new(:code, :url)
  
  def initialize(io)
    @io = io
    @results = Struct.new(:successes, :failures).new([], [])
  end
  
  def report(result)
    return if result.nil?
    
    unless result.success # collection = result.success ? results.successes : results.failures
      results.failures << IOResultOverview.new(
        result.code, result.url
      )
    end
  end
  
  def finish_report(test_name)
    unless (failures).empty?
      io.puts "****** FAILURES"
      failures.each do |failure|
        io.puts "#{failure.code}: #{failure.url}"
      end
      raise "#{failures.size} failures"
    end
  end
  
end