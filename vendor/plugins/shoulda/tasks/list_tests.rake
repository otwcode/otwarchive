def list(file)
  load file
  klass = File.basename(file, '.rb').classify.constantize
  
  puts klass.name.gsub('Test', '')

  test_methods = klass.instance_methods.grep(/^test/).map {|s| s.gsub(/^test: /, '')}.sort
  test_methods.each {|m| puts "  " + m }
end

namespace :shoulda do
  desc "List the names of the test methods in a specification like format
Can take an optional FILE=./path/to/file to get the methods just for that file"
  task :list do

    require 'test/unit'
    require 'rubygems'
    require 'active_support'

    # bug in test unit.  Set to true to stop from running.
    Test::Unit.run = true

    if ENV['FILE']
      list ENV['FILE'] 
    else
      test_files = Dir.glob(File.join('test', '**', '*_test.rb'))
      test_files.each do |file|
        list(file)
      end
    end

  end
end
