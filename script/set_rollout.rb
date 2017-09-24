require 'optparse'
require 'redis'
require 'rollout'
require_relative '../config/environment'

rollout = Rollout.new(REDIS_ROLLOUT)
value = nil
parser = OptionParser.new do |options|
  options.on '-d', '--display rollout_name', 'Display the value of a rollout variable.' do |arg|
    puts rollout.get(arg.to_sym).percentage
  end
  options.on '-v', '--value value', 'The value to set the variable to' do |arg|
    value = arg.to_i
    puts "value #{value}"
  end
  options.on '-s', '--set rollout_name', 'Sets the value of a rollout variable' do |arg|
    if value.nil?
      puts "Supply a value with -v"
    else
      rollout.activate_percentage(arg.to_sym, value)
    end
  end
end

parser.parse! ARGV
