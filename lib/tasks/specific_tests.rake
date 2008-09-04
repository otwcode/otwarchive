# A little task to run specific tests or test files
# from http://mentalized.net/journal/2006/07/28/run_specific_tests_via_rake/
# 
# rake test:blog
# => Runs the full BlogTest unit test
# 
# rake test:blog:create
# => Runs the tests matching /create/ in the BlogTest unit test
# 
# rake test:blog_controller
# => Runs all tests in the BlogControllerTest functional test
# 
# rake test:blog_controller
# => Runs the tests matching /create/ in the BlogControllerTest functional test 
rule "" do |t|
  # test:file:method
  if /test:(.*)(:([^.]+))?$/.match(t.name)
    arguments = t.name.split(":")[1..-1]
    file_name = arguments.first
    test_name = arguments[1..-1] 
    
    if File.exist?("test/unit/#{file_name}_test.rb")
      run_file_name = "unit/#{file_name}_test.rb" 
    elsif File.exist?("test/functional/#{file_name}_controller_test.rb")
      run_file_name = "functional/#{file_name}_controller_test.rb" 
    elsif File.exist?("test/functional/#{file_name}_test.rb")
      run_file_name = "functional/#{file_name}_test.rb" 
    end
    
    sh "ruby -Ilib:test test/#{run_file_name} -n /#{test_name}/" 
  end
end