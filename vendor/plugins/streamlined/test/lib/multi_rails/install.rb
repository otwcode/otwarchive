require 'fileutils'

BAR = "=" * 80
RUNNER_PATH = "script/multi_rails_runner"
ACTUAL_PATH = File.expand_path(File.join(RAILS_ROOT, "/vendor/plugins/multi_rails/bin/multi_rails_runner.rb"))

puts BAR
puts "Installing multi_rails, and settig up /script/multi_rails_runner."

FileUtils.symlink(ACTUAL_PATH, RUNNER_PATH, :force => true)
`chmod +x #{RAILS_ROOT}/script/multi_rails_runner`
puts "Run '#{RUNNER_PATH} bootstrap' to add the necessary multi_rails require line to the top of your environment.rb file."
puts "Once that has been done, run '#{RUNNER_PATH}' from the root of our project to test your Rails app against all your versions of Rails."
puts "Happy Testing !"
puts BAR