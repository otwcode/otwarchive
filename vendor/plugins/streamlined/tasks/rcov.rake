begin
  require 'rcov'
  require "rcov/rcovtask"

  namespace :coverage do
    rcov_output = ENV["CC_BUILD_ARTIFACTS"] || 'tmp/coverage'
    rcov_exclusions = %w{
      tasks/relevance_extensions_tasks.rake
      lib/streamlined/integration_tests.rb
      lib/relevance/integration_test_support.rb
      lib/relevance/controller_test_support.rb
    }.join(',')
  
    desc "Delete aggregate coverage data."
    task(:clean) { rm_f "rcov_tmp" }
  
    Rcov::RcovTask.new(:unit_for_combined_report => :clean) do |t|
      t.test_files = FileList['test/unit/**/*_test.rb']
      t.rcov_opts = ["--sort coverage", "--aggregate 'rcov_tmp'", "--html", "--rails", "--exclude '#{rcov_exclusions}'"]
      t.output_dir = rcov_output + '/unit'
    end
  
    desc "Generate combined unit and functional test coverage report"
    Rcov::RcovTask.new(:unit_and_functional => :unit_for_combined_report) do |t|
      t.test_files = FileList['test/functional/**/*_test.rb']
      t.rcov_opts = ["--sort coverage", "--aggregate 'rcov_tmp'", '--html', '--rails', "--exclude '#{rcov_exclusions}'"]
      t.output_dir = rcov_output + '/unit_and_functional'
    end
  
    desc "Generate and open coverage report"
    task(:all => [:unit_for_combined_report, :unit_and_functional]) do
      system("open #{rcov_output}/unit_and_functional/index.html") if PLATFORM['darwin']
    end
  end
rescue LoadError
  if RUBY_PLATFORM =~ /java/
    puts 'running in jruby - rcov tasks not available'
  else
    puts 'sudo gem install rcov # if you want the rcov tasks'
  end
end
